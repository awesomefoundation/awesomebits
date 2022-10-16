step 'save and open the page' do
  save_and_open_page
end

step 'I am on the homepage' do
  visit(root_url)
end

step 'I submit a project to the :name chapter' do |name|
  click_link("Apply")
  step 'I fill in the application form'
  click_button("Apply")
end

step 'I fill in the application form' do
  @about_me ||= "I am awesome"
  fill_in("Your name", :with => "Mr. Awesome")
  fill_in("Project title", :with => "Awesomeness")
  fill_in("Project website", :with => "http://awesome.com")
  fill_in("Email", :with => "awesome@awesome.com")
  fill_in("Phone", :with => "")
  fill_in("project_about_me", :with => @about_me)
  fill_in("project_about_project", :with => "I want to make awesomeness.")
  fill_in("project_use_for_money", :with => "I'll spend it on stuff. Obviously.")
  select("Any", :from => "Select chapter to apply to")
end

step 'I submit a spam project to the :name chapter' do |name|
  @about_me = "--test-spam-string--"
  step "I submit a project to the #{name} chapter"
end

step 'I should see them on the application form' do
  click_link("Apply")
  select(@current_chapter.name, :from => "Select chapter to apply to")
  fill_in("New Stuff 1", :with => "Something")
  fill_in("New Stuff 2", :with => "Something")
  fill_in("New Stuff 3", :with => "Something")
  click_button("Apply")
end

step 'I select the chapter to apply to' do
  select(@current_chapter.name, :from => "Select chapter to apply to")
end

step 'I submit a project to the :name chapter with the extra questions answered' do |name|
  @project_title = "Crusades!"
  click_link("Apply")
  fill_in("Your name", :with => "Arthur")
  fill_in("Project title", :with => @project_title)
  fill_in("Project website", :with => "http://awesome.com")
  fill_in("Email", :with => "awesome@awesome.com")
  fill_in("Phone", :with => "")
  fill_in("project_about_me", :with => "I am awesome.")
  fill_in("project_about_project", :with => "I want to make awesomeness.")
  fill_in("project_use_for_money", :with => "Buying stuff.")
  select(@current_chapter.name, :from => "Select chapter to apply to")
  @extra_answer_1 = "Arthur of Camelot."
  fill_in(@extra_question_1, :with => @extra_answer_1)
  @extra_answer_2 = "I seek the Grail."
  fill_in(@extra_question_2, :with => @extra_answer_2)
  @extra_answer_3 = "What do you mean? An African or European swallow?"
  fill_in(@extra_question_3, :with => @extra_answer_3)
  click_button("Apply")
end

step 'I should be thanked' do
  expect(page.body).to match(/#{I18n.t("projects.success.title")}/)
end

step 'I should get an email telling me the application went through' do
  deliveries = ActionMailer::Base.deliveries.select do |email|
    email.subject =~ /applying/ && email.to.include?("awesome@awesome.com")
  end
  expect(deliveries.size).to eq(1)
end

step 'I submit a project to the :name chapter, but it fails' do |name|
  click_link("Apply")
  click_button("Apply")
end

step 'I should see the error' do
  expect(page).to have_css(%q[.field_with_errors #project_title+.error:contains("can't be blank")])
end

step 'I should see the notice flash' do
  expect(page).to show_the_flash("notice")
end

step 'the project count should be :num' do |num|
  expect(Project.count).to eq(num.to_i)
end

step 'I fix the error and resubmit' do
  click_link("Apply")
  fill_in("Your name", :with => "Mr. Awesome")
  fill_in("Project title", :with => "Awesomeness")
  fill_in("Project website", :with => "http://awesome.com")
  fill_in("Email", :with => "awesome@awesome.com")
  fill_in("Phone", :with => "")
  fill_in("project_about_me", :with => "I am awesome.")
  fill_in("project_about_project", :with => "I want to make awesomeness.")
  fill_in("project_use_for_money", :with => "Buying stuff.")
  select("Any", :from => "Select chapter to apply to")
  click_button("Apply")
end

step 'I have not navigated anywhere yet' do
end

step 'I refresh the page' do
  visit(page.current_path)
end
