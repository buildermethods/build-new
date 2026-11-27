require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @user.update!(onboarded_at: nil)
  end

  test "new users are sent to the welcome page from the root" do
    log_in_as(@user)
    get root_path
    assert_redirected_to welcome_path
  end

  test "welcome lists the starter tasks" do
    log_in_as(@user)
    get welcome_path
    assert_response :success
    assert_includes response.body, "Wipe kitchen countertops"
  end

  test "completing onboarding creates chosen tasks and lands on a first quest" do
    log_in_as(@user)
    assert_difference -> { @user.tasks.count }, 2 do
      post welcome_path, params: { display_name: "Gemma", task_keys: %w[counters laundry_on] }
    end
    assert_response :redirect
    assert_match(/just=1/, response.location)
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Good"
    assert_includes response.body, "Gemma"
  end

  test "skipping onboarding still marks the user onboarded" do
    log_in_as(@user)
    post skip_welcome_path
    assert @user.reload.onboarded?
    get root_path
    assert_response :success
  end

  test "onboarded users are redirected away from the welcome page" do
    log_in_as(users(:one))
    get welcome_path
    assert_redirected_to root_path
  end

  test "unknown starter keys are ignored" do
    log_in_as(@user)
    assert_no_difference -> { @user.tasks.count } do
      post welcome_path, params: { task_keys: %w[nope] }
    end
  end
end
