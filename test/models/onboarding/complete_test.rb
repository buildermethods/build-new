require "test_helper"

class Onboarding::CompleteTest < ActiveSupport::TestCase
  setup do
    @user = users(:two)
    @user.update!(onboarded_at: nil)
    @user.tasks.destroy_all
    @draft = Onboarding::Draft.new(@user)
    @draft.rooms = { "kitchen" => 1 }
    @draft.chores = %w[kitchen.wipe_sides]
  end

  def complete(**opts)
    Onboarding::Complete.call(user: @user, draft: @draft, **opts)
  end

  test "builds tasks, gifts a fern, saves preferences and marks onboarded" do
    complete(display_name: "  Gemma  ", anchor: "after dinner", treat: "A podcast")
    @user.reload
    assert @user.onboarded?
    assert_equal "Gemma", @user.display_name
    assert_equal "after dinner", @user.anchor
    assert_equal "A podcast", @user.treat
    assert_equal 1, @user.tasks.count
    assert_equal "fern_pot", @user.sanctuary_placements.find_by!(slot: "plant").decoration_key
    assert_empty @user.onboarding_draft
  end

  test "an unknown anchor is ignored" do
    complete(anchor: "whenever")
    assert_nil @user.reload.anchor
  end

  test "running twice does nothing the second time" do
    complete
    assert_not complete
    assert_equal 1, @user.tasks.count
  end

  test "skipping creates no tasks but marks onboarded" do
    Onboarding::Complete.call(user: @user, draft: Onboarding::Draft.new(User.new))
    assert @user.reload.onboarded?
    assert_equal 0, @user.tasks.count
  end

  test "reset wipes game data and restarts onboarding" do
    user = users(:one)
    tasks(:wipe_counters).complete!(today: Date.new(2026, 5, 6))
    user.routines.create!(name: "R")
    user.progress.update!(coins: 100)
    Game::PurchaseDecoration.call(user: user, key: "fern_pot")

    Onboarding::Reset.call(user: user)
    user.reload
    assert_not user.onboarded?
    assert_equal 0, user.tasks.count
    assert_equal 0, user.routines.count
    assert_equal 0, user.owned_decorations.count
    assert_equal 0, RewardTransaction.where(user: user).count
    assert_equal 0, user.progress.xp
  end

  test "reset leaves other users alone" do
    @user.tasks.create!(title: "Mine")
    Onboarding::Reset.call(user: users(:one))
    assert_equal 1, @user.tasks.count
  end

  test "reset also clears to-dos, battles, badges, intentions and cottage rooms" do
    user = users(:one)
    user.todos.create!(title: "x")
    battle = BossBattle.build_for(user, title: "B", monster_key: "toy_swarm", stage_titles: %w[a b c]).tap(&:save!)
    battle.stages.each { |s| battle.complete_stage!(s) }
    user.user_achievements.create!(key: "first_victory", earned_at: Time.current)
    user.daily_intentions.create!(task: tasks(:wipe_counters), on_date: user.today)
    user.progress.update!(xp: Game::Economy.xp_to_reach(8))
    assert Sanctuary::Equip.unlocked?(user, "garden")

    Onboarding::Reset.call(user: user)
    user.reload
    assert_equal 0, user.todos.count
    assert_equal 0, user.boss_battles.count
    assert_equal 0, user.user_achievements.count
    assert_equal 0, user.daily_intentions.count
    assert_equal 1, user.progress.reload.peak_level
    assert_not Sanctuary::Equip.unlocked?(user, "garden")
    assert Sanctuary::Equip.unlocked?(user, "living_room")
  end

  test "Equip works inside a larger transaction" do
    @user.owned_decorations.create!(decoration_key: "fern_pot")
    User.transaction { assert Sanctuary::Equip.call(user: @user, key: "fern_pot") }
    assert_equal "fern_pot", @user.sanctuary_placements.find_by!(slot: "plant").decoration_key
  end
end
