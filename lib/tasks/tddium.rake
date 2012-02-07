namespace :tddium do
  desc "Setup the database for tddium. https://gist.github.com/1519804"
  task :db_hook do
    Rake::Task["db:create"].invoke
    if File.exists?(File.join(Rails.root, "db", "schema.rb"))
      Rake::Task['db:schema:load'].invoke
    else
      Rake::Task['db:migrate'].invoke
    end
  end
end
