source 'http://rubygems.org'

gem 'rails', '3.2.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'country_select'
gem 'pg', '~> 0.13.2'
gem 'jquery-rails'
gem 'clearance', '~> 0.16.2'
gem 'thin'
gem 'sass'
gem 'high_voltage', '~> 1.1.1'
gem 'paperclip', '~> 3.0.3'
gem 'fog'
gem 'formtastic'
gem 'flutie'
gem 'bourbon', '~> 1.4.0'
gem 'copycopter_client'
gem "simple_form", :git => "https://github.com/plataformatec/simple_form.git"
gem 'nokogiri'
gem "pry"
gem "pry-nav"
gem "pry-stack_explorer"
gem "will_paginate", "~> 3.0.3"
gem "friendly_id", "~> 4.0.1"

group :development do
  gem "heroku", '~> 2.25'
  gem "hirb"
end

group :development, :test do
  gem "rspec-rails"
  gem "ruby-debug19"
  gem "sham_rack"
  gem "tddium"
  gem "evergreen", :require => "evergreen/rails"
end

group :test do
  gem "turnip"
  gem "capybara"
  gem "database_cleaner"
  gem "capybara-webkit", "0.7.1"
  gem "factory_girl_rails", "~> 3.3.0"
  gem "bourne"
  gem "timecop"
  gem "shoulda-matchers"
  gem "launchy"
  gem "email_spec"
  gem "database_cleaner"
  gem "sham_rack"
end

group :staging, :production do
  gem 'newrelic_rpm', '~> 3.3.4'
  gem 'sprockets-redirect'
end
