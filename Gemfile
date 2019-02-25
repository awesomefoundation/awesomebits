source 'http://rubygems.org'

ruby '2.1.7'

gem 'rails', '4.2.11'
gem 'rake', '< 11.0'

gem 'country_select', '~> 1.1.3'
gem 'pg', '~> 0.20.0'
gem 'textacular', '~> 4.0', :require => 'textacular/searchable'
gem 'jquery-rails', '~> 2.1.0'
gem 'clearance', '~> 1.5.0'
gem 'sass'
gem 'high_voltage', '~> 1'
gem 'paperclip', '~> 4.1.1'
gem 'fog'
gem 'formtastic'
gem 'flutie'
gem 'bourbon', '~> 1.4.0'
gem "simple_form", "~> 3.0"
gem 'nokogiri', '~> 1.6.8.1'
gem "will_paginate", "~> 3.0.3"
gem "friendly_id", "~> 5.2.4"
gem 'redcarpet'
gem 'honeypot-captcha'
gem 'sucker_punch', '~> 1.0'
gem 's3_file_field'
gem 'html_pipeline_rails'
gem 'magnific-popup-rails'
gem 'rack-attack'
gem 'rack-ssl-enforcer'
gem 'rollbar'
gem 'sass-rails', '~> 4.0'
gem 'coffee-rails'
gem 'uglifier'

# TODO transition to strong parameters
gem 'protected_attributes'

group :development do
  gem "letter_opener"
  gem 'thin'
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem "rspec-rails", "~> 3.6.1"
  gem "byebug"
  gem "sham_rack"
  gem "pry"
  gem "pry-nav"
  gem "evergreen", "~> 1.1.3", :require => "evergreen/rails"
  gem "dotenv-rails"
end

group :test do
  gem "turnip"
  gem "capybara"
  gem "database_cleaner"
  gem "capybara-webkit", "~> 1.3.0"
  gem 'capybara-screenshot'
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
  gem 'passenger'
  gem 'rails_12factor'
end
