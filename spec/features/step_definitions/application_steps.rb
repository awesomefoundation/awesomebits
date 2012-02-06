step 'I am on the homepage' do
  visit(root_url)
end

step 'I submit a project to the :name chapter' do
  click_link("Apply")
  fill_in("Name", :with => "Mr. Awesome")
  fill_in("Project title", :with => "Awesomeness")
  fill_in("Project website", :with => "http://awesome.com")
  fill_in("Email", :with => "awesome@awesome.com")
  fill_in("Phone", :with => "")
  fill_in("About me", :with => "I am awesome.")
  fill_in("About the project", :with => "I want to make awesomeness.")
  select("Any", :from => "Select chapter to apply to")
  click_button("Apply")
end

step 'I should be thanked' do
  page.should show_the_flash("notice").containing("Thanks for applying")
end

step 'I should get an email telling me the application went through' do
  deliveries = ActionMailer::Base.deliveries.select do |email|
    email.subject =~ /applying/ && email.to.include?("awesome@awesome.com")
  end
  deliveries.should have(1).item
end

step 'I submit a project to the :name chapter, but it fails' do
  click_link("Apply")
  click_button("Apply")
end

step 'I should see the error' do
  page.should have_css(%q[.field_with_errors #project_title+.error:contains("can't be blank")])
end

step 'I fix the error and resubmit' do
  click_link("Apply")
  fill_in("Name", :with => "Mr. Awesome")
  fill_in("Project title", :with => "Awesomeness")
  fill_in("Project website", :with => "http://awesome.com")
  fill_in("Email", :with => "awesome@awesome.com")
  fill_in("Phone", :with => "")
  fill_in("About me", :with => "I am awesome.")
  fill_in("About the project", :with => "I want to make awesomeness.")
  select("Any", :from => "Select chapter to apply to")
  click_button("Apply")
end

step 'I have not navigated anywhere yet' do
end

step 'I refresh the page' do
  visit(page.current_path)
end
