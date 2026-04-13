require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @password = "password" # matches test/fixtures/users.yml
  end

  test "GET /login renders the login page" do
    get login_path
    assert_response :success
  end

  test "logs in with valid credentials and redirects to the dashboard" do
    assert_difference -> { Session.count }, 1 do
      post login_path, params: {
        email: @user.email,
        password: @password
      }
    end

    assert_redirected_to dashboard_path
  end

  test "rejects invalid credentials" do
    assert_no_difference -> { Session.count } do
      post login_path, params: {
        email: @user.email,
        password: "wrong-password"
      }
    end

    assert_redirected_to login_path
  end

  test "rejects an unknown email" do
    assert_no_difference -> { Session.count } do
      post login_path, params: {
        email: "ghost@example.com",
        password: "whatever"
      }
    end

    assert_redirected_to login_path
  end

  test "unauthenticated users cannot reach the dashboard" do
    get dashboard_path
    assert_redirected_to login_path
  end

  test "authenticated users can reach the dashboard" do
    post login_path, params: {
      email: @user.email,
      password: @password
    }

    get dashboard_path
    assert_response :success
  end

  test "DELETE /logout terminates the session and redirects to login" do
    post login_path, params: {
      email: @user.email,
      password: @password
    }

    assert_difference -> { Session.count }, -1 do
      delete logout_path
    end

    assert_redirected_to login_path

    get dashboard_path
    assert_redirected_to login_path
  end
end
