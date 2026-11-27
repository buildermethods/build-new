require "test_helper"

Capybara.enable_aria_label = true
Capybara.default_max_wait_time = 8

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # With Chrome 158 and selenium-webdriver 4.38, a second native click or key
  # press in the same page is sometimes dropped before it reaches the page
  # (the same mismatch behind the "* is not a valid URL" teardown error). Use
  # this for steps with several rapid interactions. Real browsers are fine.
  def js_click(element)
    page.execute_script("arguments[0].click()", element)
  end
end
