require "application_system_test_case"

class OnboardingTest < ApplicationSystemTestCase
  test "a new user picks starter chores and gets a first quest" do
    users(:two).update!(onboarded_at: nil)
    visit login_path
    fill_in "Email", with: users(:two).email
    fill_in "Password", with: "password"
    click_button "Log in"

    assert_text "Welcome to Nest Quest"
    fill_in "What should we call you?", with: "Gemma"
    click_button "Begin my adventure"

    assert_text "Good", wait: 5
    assert_text "Gemma!"
    assert_text "Your next quest"
    assert_selector "svg[aria-label*='Fern in a Pot']"
  end
end
