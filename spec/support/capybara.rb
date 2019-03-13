require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs: { browser: 'ALL' })
  opts = Selenium::WebDriver::Chrome::Options.new

  chrome_args = %w[--headless --window-size=1920,1080 --no-sandbox --disable-dev-shm-usage]
  chrome_args.each { |arg| opts.add_argument(arg) }
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts, desired_capabilities: caps)
end

Capybara.configure do |config|
  # change this to :chrome to observe tests in a real browser
  if ENV['HEADLESS'] == 'false'
    config.javascript_driver = :chrome
  else
    config.javascript_driver = :headless_chrome
  end
end

Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara::Screenshot.register_driver(:chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end
