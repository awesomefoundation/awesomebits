require './config/environment'
require 'capybara-webkit'

Evergreen.configure do |config|
  config.public_dir = '.'
  config.driver = :webkit
end
