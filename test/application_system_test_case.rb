require "test_helper"

Capybara.enable_aria_label = true
Capybara.default_max_wait_time = 8

# Capybara 3.40's final reset step asks Chrome to clear storage for origin "*",
# which Chrome 158+ rejects ("invalid argument: * is not a valid URL"). That
# call comes after cookies, storage and the page were already cleared, so
# ignoring this one error is safe. Remove once Capybara handles it.
module ChromeResetFix
  def reset!
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => e
    raise unless e.message.include?("is not a valid URL")
  end
end
require "capybara/selenium/driver"
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetFix)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Even with a current selenium-webdriver, headless Chrome 158 occasionally
  # drops a native click when several are sent in quick succession. Use this
  # for steps with many rapid interactions. Real browsers are fine.
  def js_click(element)
    page.execute_script("arguments[0].click()", element)
  end

  # Likewise keystrokes are sometimes dropped, so set a React-controlled
  # input's value the way React expects (native setter plus an input event).
  def js_fill(element, value)
    page.execute_script(<<~JS, element, value)
      const el = arguments[0];
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value").set.call(el, arguments[1]);
      el.dispatchEvent(new Event("input", { bubbles: true }));
    JS
  end
end
