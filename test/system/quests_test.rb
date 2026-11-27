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
    within("[role=dialog]") do
      fill_in "Task", with: "Water plants"
      fill_in "Minutes", with: "5"
      select "Tiny", from: "Effort"
      click_button "Add quest"
    end
    assert_text "Water plants"

    within(find("article", text: "Water plants")) { click_button "Complete" }
    assert_text "defeated!"
    assert_text "+15 XP"
    click_button "Lovely"
    assert_no_selector "article", text: "Water plants"
    assert_text "15 / 100 XP to level 2"
    assert_text "Recently completed"
    assert_selector "li", text: /Water plants/
  end

  test "filters by difficulty" do
    assert_text "Wipe kitchen countertops"
    click_button "Boss"
    assert_text "No quests match these filters."
  end
end
