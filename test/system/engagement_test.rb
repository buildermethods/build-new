require "application_system_test_case"

class EngagementTest < ApplicationSystemTestCase
  setup do
    visit login_path
    js_fill find_field("Email"), users(:one).email
    js_fill find_field("Password"), "password"
    js_click find_button("Log in")
    assert_current_path root_path
  end

  test "add, tick, edit and delete a quick to-do" do
    visit todos_path
    js_fill find_field("New to-do"), "Call the plumber"
    js_click find_button("Add")
    assert_text "Call the plumber"

    js_click find_field("Mark done: Call the plumber", visible: :all)
    assert_text "Done! +2 XP"
    assert_selector "[aria-label='Done'] p.line-through", text: "Call the plumber"

    js_click find_button("Delete Call the plumber")
    assert_no_text "Call the plumber"
  end

  test "start a boss battle from a template and clear a stage" do
    visit new_boss_battle_path
    assert_text "Start from a template"
    js_click find_button("Start the battle")
    assert_text "Slay the clutter pile"
    assert_text "100 / 100 HP"

    js_click find_field("Stage 1. Clear one surface completely", visible: :all)
    assert_text "Stage cleared!"
    assert_text "80 / 100 HP"
  end

  test "the codex, insights, badges and challenges all load" do
    visit codex_path
    assert_text "Monster Codex"
    assert_text "Undiscovered monster", count: 8

    visit insights_path
    assert_text "Last four weeks"
    assert_selector "[aria-label='Quests finished each week']"

    visit achievements_path
    assert_text "Next to earn"

    visit root_path
    assert_selector "section[aria-label='Challenges']"
    assert_text "Optional extras"
  end

  test "the sanctuary shows locked rooms and the living room" do
    visit sanctuary_path
    assert_selector "button[aria-pressed='true']", text: "Living room"
    assert_selector "button[disabled]", text: "Kitchen"
    assert_text "level 3"
  end
end
