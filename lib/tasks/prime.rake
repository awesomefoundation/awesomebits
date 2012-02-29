namespace :app do
  namespace :dev do
    desc "Prime development database"
    task :prime => :environment do
      require 'database_cleaner'
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean

      require 'factory_girl_rails'

      Rake::Task['db:seed'].execute

      chapter_boston = FactoryGirl.create(:chapter, :name => "Boston")

      user = FactoryGirl.create(:user, :email => "boston@example.com")
      user.update_password("12345")
      FactoryGirl.create(:role, :user => user, :chapter => chapter_boston)
      user = FactoryGirl.create(:user, :email => "boston+dean@example.com")
      user.update_password("12345")
      FactoryGirl.create(:role, :user => user, :chapter => chapter_boston, :name => "dean")

      chapter_la = FactoryGirl.create(:chapter, :name => "LA")

      user = FactoryGirl.create(:user, :email => "la@example.com")
      user.update_password("12345")
      FactoryGirl.create(:role, :user => user, :chapter => chapter_la)
      user = FactoryGirl.create(:user, :email => "la+dean@example.com")
      user.update_password("12345")
      FactoryGirl.create(:role, :user => user, :chapter => chapter_la, :name => "dean")

      project = FactoryGirl.create(:project, :chapter => chapter_boston)
      project = FactoryGirl.create(:project, :chapter => chapter_boston)
      project = FactoryGirl.create(:project, :chapter => chapter_la)

      puts <<-end_doc
An admin user has been created: admin@awesomefoundation.org / gnarly

The "Any" chapter has been created

A Boston chapter has been created with a trustee: boston@example.com / 12345
  and a dean: boston+dean@example.com / 12345

An LA chapter has been created with a trustee: la@example.com / 12345
  and a dean: la+dean@example.com / 12345

Two projects have been created for the Boston chapter.
One project has been created for the LA chapter.
      end_doc
    end
  end

  namespace :staging do
    desc "Prime staging"
    task :prime => :environment do
      u = User.new(:first_name => "Admin", :last_name => "Admin", :email => "admin@awesomefoundation.org")
      u.password = "12345"
      u.admin = true
      u.save
      u.update_password("gnarly")
      bt = User.new(:first_name => "Boston", :last_name => "Trustee", :email => "boston@example.com")
      bt.password = "12345"
      bt.save
      bd = User.new(:first_name => "Boston", :last_name => "Dean", :email => "boston+dean@example.com")
      bd.password = "12345"
      bd.save
      bos = Chapter.create(:name => "Boston")
      r = Role.new
      r.chapter = bos
      r.user = bt
      r.name = "trustee"
      r.save
      r = Role.new
      r.user = bd
      r.name = "dean"
      r.chapter = bos
      r.save
      Chapter.create(:name => "Any")
    end
  end
end
