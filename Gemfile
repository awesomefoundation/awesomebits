source 'https://rubygems.org'

ruby '2.7.6'

gem 'rails', '5.2.8.1'
gem 'rake', '< 13.0'
gem 'bootsnap','>= 1.1.0', require: false

gem 'addressable'
gem 'aws-sdk-s3'
gem 'puma'
gem 'pg', '~> 0.20.0'
gem 'textacular', '~> 5.1.0'
gem 'it'
gem 'jquery-rails', '~> 4.1.1'
gem 'jquery-ui-rails', '~> 3.0.1'
gem 'clearance', '~> 1.13.0'
gem 'clearance-deprecated_password_strategies'
gem 'high_voltage', '~> 1'
gem 'formtastic'
gem 'flutie'
gem 'bourbon', '~> 4.0.2'
gem 'simple_form', '~> 4.1'
gem 'nokogiri', '~> 1.13.9'
gem "will_paginate", "~> 3.1.7"
gem "friendly_id", "~> 5.2.4"
gem 'redcarpet'
gem 'honeypot-captcha'
gem 'sucker_punch', '~> 3.1'
gem 's3_file_field'
gem 'magnific-popup-rails'
gem 'rack-attack'
gem 'rack-cors'
gem 'rack-ssl-enforcer'
gem 'rollbar'
gem 'sassc-rails', '~> 2.1'
gem 'shrine', '~> 3'
gem 'coffee-rails'
gem 'uglifier'
gem 'react-rails'
gem 'xmlrpc'
gem 'jbuilder'

group :development do
  gem "letter_opener"
  gem "listen"
  gem 'web-console'
  gem "dotenv-rails"
end

group :development, :test do
  gem "rspec-rails", "~> 3.6.1"
  gem "byebug"
  gem "sham_rack"
  gem "pry"
  gem "pry-nav"
end

group :test do
  gem "turnip"
  gem "capybara", "~> 3"
  gem "capybara-screenshot", "~> 1.0"
  gem "webdrivers"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "faker"
  gem "bourne"
  gem "timecop"
  gem "rails-controller-testing"
  gem "shoulda-matchers", "~> 3"
  gem "launchy"
  gem "email_spec"
end

group :staging, :production do
  gem 'newrelic_rpm', '~> 8.11.0'
  gem 'sprockets-redirect'
  gem 'rails_12factor'
end
