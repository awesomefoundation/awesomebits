step 'I promote the trustee to admin' do
  @current_chapter = FactoryGirl.create(:chapter)
  visit chapter_projects_path(@current_chapter)
  click_link("View all Users")
  page.find(:css, "tr[data-user-id='#{@trustee.id}'].trustee a.admin-toggle").click
end

step 'I should see the new admin' do
  page.should have_css("tr[data-user-id='#{@trustee.id}'].admin")
end
