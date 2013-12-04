source 'http://rubygems.org'

# Fix for simple_form encoding installation problem
# http://stackoverflow.com/questions/7095845/when-run-bundle-get-invalid-byte-sequence-in-us-ascii
if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '3.2.14'

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
gem "clearance", "~> 1.1.0"
gem 'thin'
gem 'sass'
gem 'high_voltage'
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
gem "friendly_id", "~> 4.0.9"
gem 'airbrake'
gem 'redcarpet'
gem 'honeypot-captcha'
gem "faker"

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
  gem 'capybara-webkit', :git => "https://github.com/thoughtbot/capybara-webkit.git"
  #gem "capybara-webkit", "0.7.1"
  gem "factory_girl_rails"
  gem "bourne"
  gem "timecop"
  gem "shoulda-matchers"
  gem "launchy"
  gem "email_spec"
  gem "database_cleaner"
  gem "sham_rack"
end

group :staging, :production do
  gem 'newrelic_rpm'
  gem 'sprockets-redirect'
  gem 'unicorn'
end


ruby "1.9.2"
