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

  test "check in, ask what to do, focus and finish" do
    visit root_path
    click_button "15 min"
    click_button "Gentle Adventure"
    click_button "Just tell me what to do"
    assert_text "Your next quest"
    assert_text "To do:"

    click_button "Start"
    within("[role=dialog]") do
      assert_selector "[role=timer]"
      click_button "Complete"
    end
    assert_text "defeated!"
  end

  test "plan my quests shows a plan with a buffer" do
    visit root_path
    click_button "30 min"
    click_button "Plan my quests"
    assert_selector "section[aria-label='Your plan']"
    assert_text "free as a buffer"
  end

  test "buy and equip a decoration" do
    users(:one).progress.update!(coins: 50)
    visit sanctuary_path
    assert_text "You have 50 coins."
    within(find("li", text: "Fern in a Pot")) { click_button "Preview" }
    assert_text "Previewing Fern in a Pot"
    within(find("li", text: "Fern in a Pot")) { click_button "Buy" }
    assert_text "Fern in a Pot is yours"
    assert_text "You have 30 coins."
    within(find("li", text: "Fern in a Pot")) { click_button "Equip" }
    assert_selector "svg[aria-label*='Fern in a Pot']"
    assert_text(/Plant:\s+Fern in a Pot/)
  end

  test "create a routine and complete it for a bonus" do
    visit routines_path
    click_button "New routine"
    within("[role=dialog]") do
      fill_in "Name", with: "Evening reset"
      fill_in "Step 1 title", with: "Dishes"
      click_button "Add step"
      fill_in "Step 2 title", with: "Lights off"
      click_button "Create routine"
    end
    assert_text "0 of 2 done"
    check "Dishes"
    assert_text "1 of 2 done"
    check "Lights off"
    assert_text "defeated!"
    assert_text "+20 XP"
  end

  test "settings: reduce motion and reset" do
    visit settings_path
    fill_in "Display name", with: "Gemma"
    check "Reduce motion"
    click_button "Save settings"
    assert_text "Settings saved."
    assert_selector "html.reduce-motion"

    click_button "Reset my game data"
    within("[role=dialog]") { click_button "Yes, reset" }
    assert_text "Welcome to Nest Quest"
  end
end
