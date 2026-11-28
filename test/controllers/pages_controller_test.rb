require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "logged-out visitors see the home page" do
    get root_path
    assert_response :success
  end

  test "logged-in users see Today at root without a redirect" do
    log_in_as(users(:one))
    get root_path
    assert_response :success
    assert_includes response.body, "&quot;component&quot;:&quot;Dashboard&quot;"
    assert_includes response.body, "one_thing"
  end

  test "Today offers exactly one thing, from the user's own tasks" do
    log_in_as(users(:one))
    get root_path
    assert_match(/Banish the Counter Goblins|Tame the Laundry Troll/, response.body)
    assert_not_includes response.body, "Not yours"
    assert_equal 1, response.body.scan("&quot;one_thing&quot;:{&quot;quest&quot;:{").size
  end

  test "swapping excludes the previous suggestion" do
    log_in_as(users(:one))
    ids = users(:one).tasks.available_on(users(:one).today).map(&:id)
    get root_path, params: { exclude: ids }
    assert_includes response.body, "&quot;one_thing&quot;:{&quot;quest&quot;:null"
  end

  test "something easier never offers a larger task" do
    users(:one).tasks.destroy_all
    users(:one).tasks.create!(title: "Deep clean", effort: "large", duration_minutes: 20)
    log_in_as(users(:one))
    get root_path, params: { easier: 1, energy: "gentle" }
    assert_not_includes response.body, "Deep clean"
  end

  test "bad params fall back to safe defaults" do
    log_in_as(users(:one))
    get root_path, params: { energy: "nonsense", exclude: [ "x", "-1" ] }
    assert_response :success
  end

  test "Today greets by display name" do
    users(:one).update!(display_name: "Gemma")
    log_in_as(users(:one))
    get root_path
    assert_includes response.body, "Gemma!"
  end

  test "after a long break Today offers a fresh start" do
    tasks(:wipe_counters).complete!(today: users(:one).today, at: 10.days.ago)
    log_in_as(users(:one))
    get root_path
    assert_includes response.body, "&quot;kind&quot;:&quot;welcome_back&quot;"
  end

  test "Today shows the week and today's wins" do
    tasks(:wipe_counters).complete!(today: users(:one).today)
    log_in_as(users(:one))
    get root_path
    assert_includes response.body, "&quot;today&quot;:{&quot;wins&quot;:1"
    assert_includes response.body, "&quot;active_days&quot;:1"
  end

  test "a planned intention is sticky for the day" do
    user = users(:one)
    log_in_as(user)
    laundry = tasks(:laundry_weekly)
    post intentions_path, params: { task_id: laundry.id, anchor: "after dinner" }
    get root_path
    assert_includes response.body, "Put one load of washing on"
    assert_includes response.body, "after dinner"
  end

  test "every page carries the Nest Quest brand metadata" do
    get root_path
    assert_includes response.body, 'property="og:site_name" content="Nest Quest"'
    assert_match(%r{property="og:image" content="http://www\.example\.com/og-image\.png"}, response.body)
    assert_includes response.body, 'name="twitter:card" content="summary_large_image"'
    assert_includes response.body, 'name="theme-color" content="#19d3e3"'
    assert File.exist?(Rails.root.join("public/og-image.png"))
  end

  test "the web app manifest is branded" do
    manifest = Rails.root.join("app/views/pwa/manifest.json.erb").read
    assert_includes manifest, '"name": "Nest Quest"'
    assert_not_includes manifest, "Build New"
  end
end
