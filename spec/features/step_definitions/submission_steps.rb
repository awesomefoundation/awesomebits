step "I am on the submission page" do
  visit new_submission_path
end

step "I type into the description fields" do
  fill_in "project_description", :with => "21 characters of text"
  fill_in "project_use", :with => "this makes 19 chars"
end

step "I should see the amount of characters remaining" do
  page.should have_selector("#project_description_chars_left", :text => "2479")
  page.should have_selector("#project_use_chars_left", :text => "481")
end
