# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'turnip'
require 'turnip/capybara'
require 'database_cleaner'
require 'paperclip/matchers'
require 'sucker_punch/testing/inline'

DatabaseCleaner.strategy = :truncation
Capybara.javascript_driver = :webkit
require 'capybara-screenshot/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/features/step_definitions**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include Capybara::DSL

  config.mock_with :mocha
  config.after(:each){ DatabaseCleaner.clean }
  config.before(:each){ FactoryGirl.create(:chapter, :name => "Any") }
  config.before(:each){ ActionMailer::Base.deliveries.clear }
  config.include(Paperclip::Shoulda::Matchers)

  # TODO Rails 3.2.22.3 introduced a change that makes this required
  # for getting view tests to pass. When upgrading rspec or
  # Rails to a future version, see if this is still required.
  config.before(:suite, :type => :view) do
    class ActionView::Helpers::InstanceTag
      include ActionView::Helpers::OutputSafetyHelper
    end
  end
end
