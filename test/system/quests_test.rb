require "application_system_test_case"

class QuestsTest < ApplicationSystemTestCase
  setup do
    visit login_path
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password"
    click_button "Log in"
    assert_current_path root_path
    visit quests_path
  end

  test "add a quest and complete it" do
    click_button "Add quest"
    fill_in "Task", with: "Water plants"
    click_button "Add quest", match: :prefer_exact
    assert_text "Water plants"

    within(find("article", text: "Water plants")) { click_button "Complete" }
    assert_no_selector "article", text: "Water plants"
    assert_text "Recently completed"
    assert_selector "li", text: /Water plants/
  end

  test "filters by difficulty" do
    assert_text "Wipe kitchen countertops"
    click_button "Boss"
    assert_text "No quests match these filters."
  end
end
