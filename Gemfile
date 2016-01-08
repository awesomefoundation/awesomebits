source 'http://rubygems.org'

ruby '2.1.7'

gem 'rails', '3.2.22'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'country_select'
gem 'pg', '~> 0.13.2'
gem 'texticle', '~> 2.0', :require => 'texticle/rails'
gem 'jquery-rails'
gem 'clearance', '~> 0.16.2'
gem 'thin'
gem 'sass'
gem 'high_voltage'
gem 'paperclip', '~> 3.0.3'
gem 'fog'
gem 'formtastic'
gem 'flutie'
gem 'bourbon', '~> 1.4.0'
gem 'copycopter_client'
gem "simple_form", "~> 2.1.3"
gem 'nokogiri'
gem "will_paginate", "~> 3.0.3"
gem "friendly_id", "~> 4.0.9"
gem 'redcarpet'
gem 'honeypot-captcha'
gem 'sucker_punch', '~> 1.0'
gem 's3_file_field'
gem 'html_pipeline_rails'
gem 'magnific-popup-rails'
gem 'rack-attack'

group :development, :test do
  gem "rspec-rails"
  gem "byebug"
  gem "sham_rack"
  gem "tddium"
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
