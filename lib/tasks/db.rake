namespace :import do
  task :old_db => :environment do
    Chapter.transaction do

      ActiveRecord::Base.configurations["new_database"] = {
        adapter: "postgresql",
        database: "awesomefoundation_development",
        host: "localhost"
      }

      ActiveRecord::Base.configurations["old_database"] = {
        adapter: "mysql2",
        database: "awsm_production",
        username: "root",
        password: nil,
        host: "localhost"
      }

      require './app/models/user'
      require './app/models/chapter'
      require './app/models/project'

      class Chapter < ActiveRecord::Base
        establish_connection :new_database
      end

      class Project < ActiveRecord::Base
        establish_connection :new_database
      end

      class User < ActiveRecord::Base
        establish_connection :new_database
      end

      class Role < ActiveRecord::Base
        belongs_to :chapter
        belongs_to :user
        establish_connection :new_database
      end

      class OldUser < ActiveRecord::Base
        establish_connection :old_database
        self.table_name = "users"
        belongs_to :chapter, :class_name => "OldChapter"
      end

      class OldChapter < ActiveRecord::Base
        establish_connection :old_database
        self.table_name = "chapters"
        has_many :users, :class_name => "OldUser"
        has_many :projects, :class_name => "OldProject"
      end

      class OldProject < ActiveRecord::Base
        establish_connection :old_database
        self.table_name = "projects"
        belongs_to :chapter, :class_name => "OldChapter"
      end

      class OldSubmission < ActiveRecord::Base
        establish_connection :old_database
        self.table_name = "submissions"
        belongs_to :chapter, :class_name => "OldChapter"
      end

      Chapter.delete_all
      Project.delete_all
      User.delete_all

      begin
        puts "Converting Submissions"
        any_chapter = Chapter.new(name: "Any", description: "Any Chapter", country: "United States")
        any_chapter.save!
        OldSubmission.all.each do |os|
          chapter = os.chapter
          chapter = convert_chapter(chapter)
          chapter ||= any_chapter
          chapter.save! if chapter.new_record?

          project = convert_submission(os)
          project.chapter = chapter
          project.save!
        end
      rescue => e
        puts "Rescue -> #{e}\n#{e.backtrace.join("\n\t")}"
        pry
      end
      begin
        puts "Converting Users"
        OldUser.all.each do |user|
          new_user = convert_user(user)
          p new_user
          new_user.save!
        end
      rescue => e
        puts "Rescue -> #{e}\n#{e.backtrace.join("\n\t")}"
        raise
      end
    end
  end

  def convert_chapter(chapter)
    return nil if chapter.nil?

    new_chapter = Chapter.find_or_initialize_by_name(chapter.name)
    new_chapter.name = chapter.name
    new_chapter.description = chapter.body.blank? ? "The #{chapter.name} Chapter" : chapter.body
    new_chapter.country = "United States"
    new_chapter
  end

  def convert_submission(submission)
    new_submission = Project.new
    new_submission.use_for_money  = submission.use.blank? ? "I will use the money to be awesome." : submission.use
    new_submission.about_project  = submission.description.blank? ? "Project description." : submission.description
    new_submission.title          = submission.title.blank? ? "A Project by #{submission.name}" : submission.title
    new_submission.name           = submission.name.blank? ? "John or Jane Doe" : submission.name
    new_submission.email          = submission.email.blank? ? "nothing@example.com" : submission.email
    new_submission.phone          = submission.phone
    new_submission.url            = submission.url
    new_submission.created_at     = submission.created_at
    new_submission.updated_at     = submission.updated_at
    new_submission.about_me       = "I am an awesome person"

    old_project = OldProject.where(title: submission.title).first
    if(old_project)
      new_submission.about_project = old_project.description
      new_submission.photos << Photo.new(photo_file_name: old_project.photo_file_name, photo_content_type: old_project.photo_content_type,
                                         photo_updated_at: old_project.photo_updated_at, photo_file_size: old_project.photo_file_size)
    end

    new_submission
  end

  def convert_user(user)
    new_user = User.new

    new_user.email              = user.email.blank? ? "#{user.login.gsub(/[^a-zA-Z0-9]/,'_')}@NOT.AF.ORG" : user.email
    new_user.encrypted_password = user.crypted_password
    new_user.salt               = user.password_salt
    new_user.active             = user.active
    new_user.admin              = user.admin
    new_user.first_name         = user.first_name
    new_user.last_name          = user.last_name
    new_user.bio                = user.bio
    new_user.url                = user.url
    new_user.created_at         = user.created_at
    new_user.updated_at         = user.updated_at

    unless user.chapter.nil?
      chapter = convert_chapter(user.chapter)
      chapter.save if chapter.new_record?
      role = Role.new
      role.chapter_id = chapter.id
      new_user.roles << role
    end

    new_user
  end

end
