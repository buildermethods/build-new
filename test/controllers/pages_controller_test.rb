require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "logged-out visitors see the home page" do
    get root_path
    assert_response :success
  end

  test "logged-in users see their to-do list at root without a redirect" do
    log_in_as(users(:one))
    get root_path
    assert_response :success
    assert_includes response.body, "Buy milk"
    assert_not_includes response.body, "Not yours"
  end
end
