require "test_helper"

class InsightsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get insights_path
    assert_redirected_to login_path
  end

  test "renders the insights page" do
    log_in_as(users(:one))
    post complete_task_path(tasks(:wipe_counters))
    get insights_path
    assert_response :success
    assert_includes response.body, "&quot;component&quot;:&quot;insights/Index&quot;"
    assert_includes response.body, "&quot;this_week&quot;"
    assert_includes response.body, "&quot;weeks&quot;"
  end

  test "only shows the player's own data" do
    users(:two).tasks.create!(title: "x", room: "kitchen").complete!(today: users(:two).today)
    log_in_as(users(:one))
    get insights_path
    assert_match(/&quot;quests&quot;:0/, response.body)
  end
end
