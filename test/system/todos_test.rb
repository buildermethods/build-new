require "application_system_test_case"

class TodosTest < ApplicationSystemTestCase
  setup do
    visit login_path
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password"
    click_button "Log in"
  end

  test "add, complete, un-complete, edit and delete a to-do" do
    fill_in "New to-do", with: "Water plants"
    click_button "Add"
    assert_text "Water plants"

    within(find("li", text: "Water plants")) { find("input[type=checkbox]").click }
    assert_selector "li", text: /Water plants\s+Complete/
    within(find("li", text: "Water plants")) { find("input[type=checkbox]").click }
    assert_selector "li", text: /Water plants\s+Incomplete/

    within(find("li", text: "Water plants")) { click_button "Edit" }
    fill_in "Edit description", with: "Water ferns"
    click_button "Save"
    assert_text "Water ferns"

    within(find("li", text: "Water ferns")) { click_button "Delete" }
    assert_no_text "Water ferns"
  end

  test "filters and counts" do
    assert_text "1 of 2 complete"
    click_button "Completed"
    assert_text "Write report"
    assert_no_text "Buy milk"
  end
end
