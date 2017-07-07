step 'I promote the trustee to admin' do
  @current_chapter = FactoryGirl.create(:chapter)
  visit chapter_projects_path(@current_chapter)
  click_link("View all Users")
  page.find(:css, "tr[data-user-id='#{@trustee.id}'].non_admin td.promote-demote-admin a.promote-user").click
end

step 'I remove trustee from a chapter' do
  visit users_path
  click_link("Remove")
  page.evaluate_script('window.confirm = function() { return true; }')
end

step 'I should see the deactivated user' do
  expect(page).to have_selector(".remove-trustee", :text => '-')
end

step 'I should see the new admin' do
  expect(page).to have_css("tr[data-user-id='#{@trustee.id}'].admin")
end
