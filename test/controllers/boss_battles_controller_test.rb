require "test_helper"

class BossBattlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @battle = BossBattle.build_for(@user, title: "Slay the pile", monster_key: "doom_pile_dragon", stage_titles: %w[A B C]).tap(&:save!)
    @theirs = BossBattle.build_for(users(:two), title: "Not yours", monster_key: "toy_swarm", stage_titles: %w[A B C]).tap(&:save!)
  end

  def xp
    PlayerProgress.find_by!(user: @user).xp
  end

  test "requires authentication" do
    get boss_battles_path
    assert_redirected_to login_path
  end

  test "lists only my battles" do
    log_in_as(@user)
    get boss_battles_path
    assert_includes response.body, "Slay the pile"
    assert_not_includes response.body, "Not yours"
  end

  test "new shows the templates" do
    log_in_as(@user)
    get new_boss_battle_path
    assert_response :success
    assert_includes response.body, "Tame a wardrobe"
  end

  test "creates a battle" do
    log_in_as(@user)
    assert_difference -> { @user.boss_battles.count }, 1 do
      post boss_battles_path, params: { title: "Tame the wardrobe", monster_key: "wardrobe_wraith", stages: %w[One Two Three] }
    end
    assert_redirected_to boss_battle_path(@user.boss_battles.find_by!(title: "Tame the wardrobe"))
  end

  test "rejects too few stages" do
    log_in_as(@user)
    assert_no_difference -> { BossBattle.count } do
      post boss_battles_path, params: { title: "Tiny", monster_key: "toy_swarm", stages: %w[One] }
    end
    assert_response :redirect
  end

  test "clearing stages ends in a victory with the big reward, once" do
    log_in_as(@user)
    @battle.stages.each { |s| post complete_boss_battle_stage_path(@battle, s) }
    assert @battle.reload.defeated?
    assert_equal 30 + 150, xp
    follow_redirect!
    assert_includes response.body, "Boss defeated"
    assert_includes response.body, "Dragon Tamer"

    @battle.stages.each { |s| post complete_boss_battle_stage_path(@battle, s) }
    assert_equal 180, xp
  end

  test "double-clicking a stage pays once" do
    log_in_as(@user)
    stage = @battle.stages.first
    2.times { post complete_boss_battle_stage_path(@battle, stage) }
    assert_equal 10, xp
  end

  test "un-ticking a stage restores health" do
    log_in_as(@user)
    stage = @battle.stages.first
    post complete_boss_battle_stage_path(@battle, stage)
    post uncomplete_boss_battle_stage_path(@battle, stage)
    assert_equal 100, @battle.reload.health_remaining
  end

  test "setting a battle aside keeps it and its progress" do
    log_in_as(@user)
    post complete_boss_battle_stage_path(@battle, @battle.stages.first)
    post abandon_boss_battle_path(@battle)
    assert_redirected_to boss_battles_path
    assert_equal "abandoned", @battle.reload.status
  end

  test "cannot touch another user's battle" do
    log_in_as(@user)
    get boss_battle_path(@theirs)
    assert_response :not_found
    post abandon_boss_battle_path(@theirs)
    assert_response :not_found
    post complete_boss_battle_stage_path(@theirs, @theirs.stages.first)
    assert_response :not_found
  end

  test "Today shows an active battle" do
    log_in_as(@user)
    get root_path
    assert_includes response.body, "Slay the pile"
  end
end
