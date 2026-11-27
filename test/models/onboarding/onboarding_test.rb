require "test_helper"

class OnboardingTest < ActiveSupport::TestCase
  setup do
    @user = users(:two)
    @user.update!(onboarded_at: nil)
  end

  test "creates only the chosen catalog tasks, gifts a fern and marks onboarded" do
    Onboarding::Complete.call(user: @user, task_keys: %w[counters laundry_on made_up], display_name: "  Gemma  ")
    @user.reload
    assert @user.onboarded?
    assert_equal "Gemma", @user.display_name
    assert_equal [ "Put one load of washing on", "Wipe kitchen countertops" ], @user.tasks.where.not(id: tasks(:other_users_task).id).pluck(:title).sort
    assert @user.owned_decorations.exists?(decoration_key: "fern_pot")
    assert_equal "fern_pot", @user.sanctuary_placements.find_by!(slot: "plant").decoration_key
  end

  test "starter tasks start with valid schedules" do
    Onboarding::Complete.call(user: @user, task_keys: Game::Catalog.starter_tasks.map { |t| t["key"] }, display_name: nil)
    assert @user.tasks.all?(&:valid?)
    assert @user.tasks.where(recurrence_kind: "calendar").all? { |t| t.next_due_on.present? }
  end

  test "every starter task parses cleanly with its full title" do
    allowed = %w[key title room category duration_minutes effort recurrence_kind recurrence_interval_days recurrence_weekdays]
    Game::Catalog.starter_tasks.each do |t|
      assert_empty t.keys - allowed, "#{t['key']} has unexpected keys (an unquoted comma in YAML?)"
      assert t["title"].present?
    end
    bathroom = Game::Catalog.starter_tasks.find { |t| t["key"] == "bathroom" }
    assert_equal "Clean the sink, toilet and surfaces", bathroom["title"]
  end

  test "running twice does not duplicate anything" do
    Onboarding::Complete.call(user: @user, task_keys: %w[counters], display_name: nil)
    assert_not Onboarding::Complete.call(user: @user, task_keys: %w[counters], display_name: nil)
    assert_equal 2, @user.tasks.count # one fixture task is the other user's
  end

  test "skipping creates no tasks" do
    Onboarding::Complete.call(user: @user, task_keys: [], display_name: nil)
    assert @user.reload.onboarded?
    assert_equal 1, @user.tasks.count # just the fixture task
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
    assert_equal 0, user.progress.coins
  end

  test "reset leaves other users alone" do
    Onboarding::Reset.call(user: users(:one))
    assert_equal 1, users(:two).tasks.count
  end
end
