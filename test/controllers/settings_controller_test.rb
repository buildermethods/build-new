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

  test "saves a quiet-time anchor and a treat" do
    log_in_as(@user)
    patch settings_path, params: { anchor: "after dinner", treat: "  A favourite   podcast " }
    assert_redirected_to settings_path
    @user.reload
    assert_equal "after dinner", @user.anchor
    assert_equal "A favourite podcast", @user.treat
  end

  test "rejects an unknown anchor and an over-long treat" do
    log_in_as(@user)
    patch settings_path, params: { anchor: "at midnight", treat: "x" * 80 }
    @user.reload
    assert_nil @user.anchor
    assert_nil @user.treat
  end

  test "clearing the anchor and treat works" do
    @user.update!(anchor: "after lunch", treat: "Tea")
    log_in_as(@user)
    patch settings_path, params: { anchor: "", treat: "" }
    @user.reload
    assert_nil @user.anchor
    assert_nil @user.treat
  end

  test "settings shows the current anchor and treat and the explainer" do
    @user.update!(anchor: "after lunch", treat: "Tea")
    log_in_as(@user)
    get settings_path
    assert_includes response.body, "after lunch"
    assert_includes response.body, "&quot;anchors&quot;"
  end

  private
    def settings_reset_path_helper
      reset_settings_path
    end
end
