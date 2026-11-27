require "test_helper"

class NavPagesTest < ActionDispatch::IntegrationTest
  %i[quests_path routines_path sanctuary_path].each do |helper|
    test "#{helper} requires authentication" do
      get public_send(helper)
      assert_redirected_to login_path
    end

    test "#{helper} renders for a logged-in user" do
      log_in_as(users(:one))
      get public_send(helper)
      assert_response :success
    end
  end

  test "quest board lists only the current user's pending tasks" do
    log_in_as(users(:one))
    get quests_path
    assert_includes response.body, "Wipe kitchen countertops"
    assert_includes response.body, "Banish the Counter Goblins"
    assert_not_includes response.body, "Not yours"
    assert_not_includes response.body, "Write report"
  end
end
