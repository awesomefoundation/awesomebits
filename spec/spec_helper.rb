# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'clearance/rspec'
require 'turnip'
require 'turnip/capybara'
require 'database_cleaner'
require 'sucker_punch/testing/inline'

DatabaseCleaner.strategy = :truncation

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/features/step_definitions**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.mock_with :mocha
  config.after(:each){ DatabaseCleaner.clean }
  config.before(:each){ FactoryGirl.create(:chapter, :name => "Any") }
  config.before(:each){ ActionMailer::Base.deliveries.clear }
  config.after(:all) { FileUtils.rm_f Dir.glob(Rails.root.join("tmp", "tus-test", "*")) }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
