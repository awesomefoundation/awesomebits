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
