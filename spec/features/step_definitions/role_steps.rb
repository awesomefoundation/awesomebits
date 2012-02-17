step 'I promote the trustee to dean' do
  visit(chapter_users_path(@trustee_chapter))
  page.find(:css, "span[data-role-id='#{@trustee_role.id}'] a.promote-user").click
end

step 'I demote the dean to trustee' do
  visit(chapter_users_path(@dean_chapter))
  page.find(:css, "span[data-role-id='#{@dean_role.id}'] a.demote-user").click
end

step 'I should see the new trustee' do
  page.should have_css("span[data-role-id='#{@dean_role.id}'] a.promote-user")
end

step 'I should see the new dean' do
  page.should have_css("span[data-role-id='#{@trustee_role.id}'] a.demote-user")
end

step 'I try to promote a user' do
  visit(chapter_users_path(@trustee_chapter))
end

step 'I should not see promotion links' do
  page.should_not have_css(".demote-user")
  page.should_not have_css(".promote-user")
end

step 'I am a trustee for another chapter as well' do
  @other_current_chapter = FactoryGirl.create(:chapter)
  FactoryGirl.create(:role, :chapter => @other_current_chapter,
                            :user => @current_user)
end
