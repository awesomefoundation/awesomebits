namespace :app do
  namespace :dev do
    desc "Prime development database"
    task :prime => :environment do
      require 'database_cleaner'
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean

      require 'factory_bot_rails'

      Rake::Task['db:seed'].execute

      chapter_boston = FactoryBot.create(:chapter, :name => "Boston")

      user = FactoryBot.create(:user, :email => "boston@example.com")
      user.update_password("12345")
      FactoryBot.create(:role, :user => user, :chapter => chapter_boston)
      user = FactoryBot.create(:user, :email => "boston+dean@example.com")
      user.update_password("12345")
      FactoryBot.create(:role, :user => user, :chapter => chapter_boston, :name => "dean")

      chapter_la = FactoryBot.create(:chapter, :name => "LA")

      user = FactoryBot.create(:user, :email => "la@example.com")
      user.update_password("12345")
      FactoryBot.create(:role, :user => user, :chapter => chapter_la)
      user = FactoryBot.create(:user, :email => "la+dean@example.com")
      user.update_password("12345")
      FactoryBot.create(:role, :user => user, :chapter => chapter_la, :name => "dean")

      project = FactoryBot.create(:project, :chapter => chapter_boston)
      project = FactoryBot.create(:project, :chapter => chapter_boston)
      project = FactoryBot.create(:project, :chapter => chapter_la)

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

      User.delete_all
      u = User.new(:first_name => "Admin", :last_name => "Admin", :email => "admin@awesomefoundation.org")
      u.password = "gnarly"
      u.admin = true
      u.save
      bt = User.new(:first_name => "Boston", :last_name => "Trustee", :email => "boston@example.com")
      bt.password = "12345"
      bt.save
      bd = User.new(:first_name => "Boston", :last_name => "Dean", :email => "boston+dean@example.com")
      bd.password = "12345"
      bd.save

      Chapter.delete_all
      Chapter.create(:name => "Any")
      bos = Chapter.create(:name => "Boston", :description => "Awesome Boston!", :country => "United States")

      Role.delete_all
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
    end
  end
end
