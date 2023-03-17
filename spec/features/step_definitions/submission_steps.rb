step "I am on the submission page" do
  visit new_submission_path
end

step "I am on the submission page in embed mode" do
  visit new_submission_path(chapter: "any", mode: "embed")
end

step "I type into the description fields" do
  fill_in "project_about_me", :with => "21 characters of text"
  fill_in "project_about_project", :with => "this makes 19 chars"
  fill_in "project_use_for_money", :with => "this makes 24 chars....."
end

step "I should see the amount of characters remaining" do
  expect(page).to have_selector("#project_about_me_chars_left", :text => "479")
  expect(page).to have_selector("#project_about_project_chars_left", :text => "1981")
  expect(page).to have_selector("#project_use_for_money_chars_left", :text => "476")
end

step "I attach the file :filename to the submission" do |filename|
  photos = Rails.root.join("spec", "support", "fixtures")
  page.attach_file("files[]", Rails.root.join("spec", "support", "fixtures", filename), make_visible: true)
end

step "I should see :num attachment/attachments recognized" do |num|
  # This sleep is not the right solution and we should do something
  # else to test for whether the file was added to the page
  sleep(1)
  expect(page.all(".js-uploader__element").count).to eq(num.to_i)
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
  expect(page.all("a[rel='project-1-images']").count).to eq(2)
end
