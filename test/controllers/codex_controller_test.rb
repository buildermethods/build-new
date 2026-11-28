require "test_helper"

class CodexControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get codex_path
    assert_redirected_to login_path
  end

  test "lists every monster with discovery state" do
    log_in_as(users(:one))
    get codex_path
    assert_response :success
    assert_includes response.body, "&quot;component&quot;:&quot;codex/Index&quot;"
    Game::Catalog.monsters.each_value { |m| assert_includes response.body, m["name"] }
    assert_includes response.body, "&quot;discovered&quot;:0"
  end

  test "defeating a monster discovers it" do
    log_in_as(users(:one))
    post complete_task_path(tasks(:wipe_counters))
    get codex_path
    assert_includes response.body, "&quot;discovered&quot;:1"
  end
end
