require "test_helper"

class AchievementsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "requires authentication" do
    get achievements_path
    assert_redirected_to login_path
  end

  test "lists every badge with zero progress for a new player" do
    log_in_as(@user)
    get achievements_path
    assert_response :success
    assert_includes response.body, "&quot;component&quot;:&quot;achievements/Index&quot;"
    Game::Catalog.achievements.each_value { |a| assert_includes response.body, a["name"] }
    assert_includes response.body, "&quot;earned_count&quot;:0"
  end

  test "an earned badge is marked earned and the rest show progress" do
    log_in_as(@user)
    post complete_task_path(tasks(:wipe_counters))
    get achievements_path
    assert_includes response.body, "&quot;earned_count&quot;:1"
    assert_match(/&quot;key&quot;:&quot;first_victory&quot;,[^}]*&quot;earned&quot;:true/, response.body)
    assert_match(/&quot;key&quot;:&quot;five_minute_hero&quot;,[^}]*&quot;earned&quot;:false,[^}]*&quot;current&quot;:1/, response.body)
  end

  test "other players' badges are never shown" do
    users(:two).user_achievements.create!(key: "first_victory", earned_at: Time.current)
    log_in_as(@user)
    get achievements_path
    assert_includes response.body, "&quot;earned_count&quot;:0"
  end

  test "viewing the page awards badges earned through past work, once" do
    tasks(:wipe_counters).complete!(today: @user.today) # finished without the evaluator running
    assert_equal 0, @user.user_achievements.count
    log_in_as(@user)
    2.times { get achievements_path }
    assert_equal 1, @user.user_achievements.where(key: "first_victory").count
    assert_includes response.body, "&quot;earned_count&quot;:1"
  end
end
