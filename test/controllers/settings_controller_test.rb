require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "requires authentication" do
    get settings_path
    assert_redirected_to login_path
  end

  test "shows settings" do
    log_in_as(@user)
    get settings_path
    assert_response :success
  end

  test "saves display name and reduced motion" do
    log_in_as(@user)
    patch settings_path, params: { display_name: "Gemma", reduced_motion: true }
    assert_redirected_to settings_path
    @user.reload
    assert_equal "Gemma", @user.display_name
    assert @user.reduced_motion?
  end

  test "rejects an over-long display name" do
    log_in_as(@user)
    patch settings_path, params: { display_name: "x" * 60 }
    assert_nil @user.reload.display_name
  end

  test "reduced motion adds a class to the page" do
    @user.update!(reduced_motion: true)
    log_in_as(@user)
    get settings_path
    assert_match(/<html[^>]*reduce-motion/, response.body)
  end

  test "reset clears only my data and restarts onboarding" do
    log_in_as(@user)
    post reset_settings_path
    assert_redirected_to welcome_path
    assert_equal 0, @user.tasks.count
    assert_equal 1, users(:two).tasks.count
    assert_not @user.reload.onboarded?
  end

  private
    def settings_reset_path_helper
      reset_settings_path
    end
end
