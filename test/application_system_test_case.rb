require "test_helper"

Capybara.enable_aria_label = true
Capybara.default_max_wait_time = 8

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
