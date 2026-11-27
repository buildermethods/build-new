require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "logged-out visitors see the home page" do
    get root_path
    assert_response :success
  end

  test "logged-in users see their dashboard at root without a redirect" do
    log_in_as(users(:one))
    get root_path
    assert_response :success
    assert_includes response.body, "available_count"
  end

  test "dashboard offers rule-based suggestions from the user's tasks" do
    log_in_as(users(:one))
    get root_path
    assert_includes response.body, "Banish the Counter Goblins"
    assert_not_includes response.body, "Not yours"
  end

  test "planning with time and energy returns a plan without an AI key" do
    log_in_as(users(:one))
    get root_path, params: { minutes: 20, energy: "gentle", plan: 1, context: "my back hurts" }
    assert_response :success
    assert_includes response.body, "&quot;source&quot;:&quot;rules&quot;"
    assert_includes response.body, "Wipe kitchen countertops"
  end

  test "survival mode plans never include larger tasks" do
    users(:one).tasks.create!(title: "Deep clean oven", effort: "large", duration_minutes: 20, room: "kitchen")
    log_in_as(users(:one))
    get root_path, params: { minutes: 60, energy: "survival", plan: 1 }
    assert_not_includes response.body, "Deep clean oven"
  end

  test "just tell me what to do returns exactly one quest" do
    log_in_as(users(:one))
    get root_path, params: { just: 1, minutes: 30, energy: "ready" }
    assert_response :success
    assert_equal 1, response.body.scan("&quot;single&quot;:{&quot;quest&quot;:{").size
  end

  test "swapping excludes the previous suggestion" do
    log_in_as(users(:one))
    first = users(:one).tasks.available_on(users(:one).today).map(&:id)
    get root_path, params: { just: 1, exclude: first }
    assert_includes response.body, "&quot;quest&quot;:null"
  end

  test "bad check-in params fall back to safe defaults" do
    log_in_as(users(:one))
    get root_path, params: { minutes: "-5", energy: "nonsense", plan: 1, context: "x" * 5000 }
    assert_response :success
  end
end
