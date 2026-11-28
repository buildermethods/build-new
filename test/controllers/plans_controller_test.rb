require "test_helper"

class PlansControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get plan_path
    assert_redirected_to login_path
  end

  test "renders the first step with no plan" do
    log_in_as(users(:one))
    get plan_path
    assert_response :success
    assert_includes response.body, "&quot;component&quot;:&quot;plan/Show&quot;"
    assert_includes response.body, "&quot;plan&quot;:null"
  end

  test "planning with time and energy returns a rules plan without an AI key" do
    log_in_as(users(:one))
    get plan_path, params: { minutes: 20, energy: "gentle", plan: 1, context: "my back hurts" }
    assert_response :success
    assert_includes response.body, "&quot;source&quot;:&quot;rules&quot;"
    assert_includes response.body, "Wipe kitchen countertops"
  end

  test "survival mode plans never include larger tasks" do
    users(:one).tasks.create!(title: "Deep clean oven", effort: "large", duration_minutes: 20, room: "kitchen")
    log_in_as(users(:one))
    get plan_path, params: { minutes: 60, energy: "survival", plan: 1 }
    assert_not_includes response.body, "Deep clean oven"
  end

  test "bad params fall back to safe defaults" do
    log_in_as(users(:one))
    get plan_path, params: { minutes: "-5", energy: "nonsense", plan: 1, context: "x" * 5000 }
    assert_response :success
  end
end
