# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'turnip'
require 'turnip/capybara'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation
Capybara.javascript_driver = :webkit

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.after(:each){ DatabaseCleaner.clean }
  config.before(:each){ FactoryGirl.create(:chapter, :name => "Any") }
  config.before(:each){ ActionMailer::Base.deliveries.clear }
end
