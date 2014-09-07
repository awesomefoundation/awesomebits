step "I am on the submission page" do
  visit new_submission_path
end

step "I type into the description fields" do
  fill_in "project_about_me", :with => "21 characters of text"
  fill_in "project_about_project", :with => "this makes 19 chars"
  fill_in "project_use_for_money", :with => "this makes 24 chars....."
end

step "I should see the amount of characters remaining" do
  page.should have_selector("#project_about_me_chars_left", :text => "479")
  page.should have_selector("#project_about_project_chars_left", :text => "1981")
  page.should have_selector("#project_use_for_money_chars_left", :text => "476")
end

step "I attach a/another file to the submission" do
  page.attach_file('project_new_photos', "./app/assets/images/logo.png")
end

step "I should see the attachment was recognized" do
  page.should have_css(".image-upload .uploading")
end

step "I should (still) only see one file upload field" do
  ignore_hidden_elements = Capybara.ignore_hidden_elements
  begin
    Capybara.ignore_hidden_elements = true
    page.all("input[type='file']").should have(1).element
  ensure
    Capybara.ignore_hidden_elements = ignore_hidden_elements
  end
end

step 'I fill out the rest of the form' do
  step 'I fill in the application form'
end

step "I submit the form" do
  click_button("Apply")
end

step "the files I attached should have been uploaded" do
  step 'I am logged in as a trustee'
  click_link("Dashboard")
  step 'I look at the projects for the "Any" chapter'
  page.find('.applications a.title').click
  page.all("a[rel='project-1-images']").count.should == 2
end
