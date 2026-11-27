require "application_system_test_case"

class OnboardingTest < ApplicationSystemTestCase
  test "a new user is guided through rooms, chores and frequency to a first quest" do
    users(:two).update!(onboarded_at: nil)
    visit login_path
    fill_in "Email", with: users(:two).email
    fill_in "Password", with: "password"
    click_button "Log in"

    assert_text "Welcome to Nest Quest"
    assert_selector "nav[aria-label='Setup progress'] li[aria-current='step']", text: "Welcome"
    click_link "Let's set up my home"

    assert_text "Which rooms do you have?"
    within(find("li", text: "Bedroom")) do
      js_click find_button("Include")
      js_click find_button("More Bedroom rooms")
    end
    within(find("li", text: "Kitchen")) { js_click find_button("Include") }
    js_click find_button("Next: choose chores")

    assert_text "Which chores do you want?"
    assert_text "Wipe the kitchen sides"
    assert_text "Bedroom × 2"
    click_button(/Next: how often/)

    assert_text "How often should each one come round?"
    assert_selector "select"
    click_button "Next: almost done"

    assert_text "Almost there!"
    fill_in "What should we call you?", with: "Gemma"
    click_button "Begin my adventure"

    assert_text "Good", wait: 5
    assert_text "Gemma!"
    assert_text "Your one thing today"
    assert_selector "svg[aria-label*='Fern in a Pot']"
  end

  test "an onboarded user who revisits /welcome goes straight home" do
    visit login_path
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password"
    click_button "Log in"
    assert_current_path root_path
    visit "/welcome"
    assert_current_path root_path
  end
end
