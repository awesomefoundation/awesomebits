#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Awesomefoundation::Application.load_tasks
task(:default).clear
task :default => [:spec]

task(:spec).clear
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = ["./spec/**/*_spec.rb", ".spec/**/*.feature"]
end 
