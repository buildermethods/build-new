require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "GET /signup renders the signup page" do
    get signup_path
    assert_response :success
  end

  test "signs up a new user, starts a session, and redirects to the dashboard" do
    assert_difference -> { User.count }, 1 do
      post signup_path, params: {
        email: "new@example.com",
        password: "secret123",
        timezone: "America/Los_Angeles"
      }
    end

    assert_redirected_to dashboard_path

    user = User.find_by(email: "new@example.com")
    assert_equal "America/Los_Angeles", user.timezone
    assert user.authenticate("secret123")
  end

  test "rejects an invalid email" do
    assert_no_difference -> { User.count } do
      post signup_path, params: {
        email: "not-an-email",
        password: "secret123"
      }
    end

    assert_redirected_to signup_path
  end

  test "rejects a password shorter than 7 characters" do
    assert_no_difference -> { User.count } do
      post signup_path, params: {
        email: "short@example.com",
        password: "abc123"
      }
    end

    assert_redirected_to signup_path
  end

  test "accepts a 7-character password" do
    assert_difference -> { User.count }, 1 do
      post signup_path, params: {
        email: "seven@example.com",
        password: "abcd123"
      }
    end

    assert_redirected_to dashboard_path
  end

  test "rejects a duplicate email" do
    existing = users(:one)

    assert_no_difference -> { User.count } do
      post signup_path, params: {
        email: existing.email,
        password: "secret123"
      }
    end

    assert_redirected_to signup_path
  end

  test "signed-in users can reach the dashboard after signup" do
    post signup_path, params: {
      email: "flow@example.com",
      password: "secret123"
    }

    get dashboard_path
    assert_response :success
  end
end
