def create_user_with_role(name, role, mail, chapter)
  dean = User.find_or_create_by_first_name_and_last_name_and_email(name, role, mail)
  dean.update_password(role)
  dean.save!

  dean_role = Role.new
  dean_role.name = role
  dean_role.user = dean
  dean_role.chapter = chapter
  dean_role.save!

  dean.roles << dean_role

  dean
end


def create_projects_for_chapter chapter, projects_count
  projects_count.times do |i|
    p = Project.new
    p.chapter = chapter
    p.name =  "Project #{i}"
    p.title = Faker::Name.title
    p.email = Faker::Internet.email
    p.about_me = Faker::Lorem.sentences
    p.about_project = Faker::Lorem.sentences
    p.use_for_money = Faker::Lorem.sentences

    p.save!
  end

end

# Set up the admin user
admin = User.find_or_create_by_first_name_and_last_name_and_email("Yosy", "Admin", "yosy101@gmail.com")
admin.update_attribute(:admin, true)
admin.update_password("admin")


# Set up the chapters
any_chapter = Chapter.find_or_create_by_name("Any", :description => "Any Chapter", :country => COUNTRY_PRIORITY.first)
any_chapter.save!

test_chapter = Chapter.find_or_create_by_name("Test Chapter", :description => "Test Chapter", :country => COUNTRY_PRIORITY.second)
test_chapter.save!

# Create a sample dean and trusteer chapters
dean = create_user_with_role "Yosy", "dean", "yosy102@gmail.com", test_chapter
trusteer = create_user_with_role "Yosy", "trusteer", "yosy103@gmail.com", test_chapter


# Create a sample projects for any chapter and test chapter
create_projects_for_chapter test_chapter, 10
create_projects_for_chapter any_chapter, 2