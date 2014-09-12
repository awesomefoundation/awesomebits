source 'http://rubygems.org'

gem 'rails', '~> 3.2.17'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'country_select'
gem 'pg'
gem 'textacular'
gem 'jquery-rails'
gem 'clearance'
gem 'thin'
gem 'sass'
gem 'high_voltage'
gem 'paperclip'
gem 'fog'
gem 'formtastic'
gem 'flutie'
gem 'bourbon'
gem 'copycopter_client'
gem "simple_form", "~> 2.1.1"
gem 'nokogiri'
gem "will_paginate", "~> 3.0.3"
gem "friendly_id"
gem 'redcarpet'
gem 'honeypot-captcha'

group :development, :test do
  gem "rspec-rails", "~> 2.99"
  gem "byebug"
  gem "sham_rack"
  gem "tddium"
  gem "pry"
  gem "pry-nav"
  gem "evergreen", :require => "evergreen/rails"
end

group :test do
  gem "turnip"
  gem "capybara"
  gem "database_cleaner"
  gem "capybara-webkit", "~> 1.3.0"
  gem "factory_girl_rails"
  gem "faker"
  gem "bourne"
  gem "timecop"
  gem "shoulda-matchers"
  gem "launchy"
  gem "email_spec"
end

group :staging, :production do
  gem 'newrelic_rpm'
  gem 'sprockets-redirect'
  gem 'unicorn'
  gem 'rails_12factor'
end
