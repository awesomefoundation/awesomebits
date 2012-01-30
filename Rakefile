#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Awesomefoundation::Application.load_tasks
task(:default).clear
task :default => [:spec, "spec:features"]

namespace :spec do
  RSpec::Core::RakeTask.new(:features => ["db:test:prepare"]) do |t|
    t.pattern = "./spec/**/*.feature"
  end
end
