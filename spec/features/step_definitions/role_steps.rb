step 'I promote the trustee to dean' do
  visit(users_path)
  page.find(:css, "li[data-role-id='#{@trustee_role.id}'] a.promote-user").click
end

step 'I demote the dean to trustee' do
  visit(users_path)
  page.find(:css, "li[data-role-id='#{@dean_role.id}'] a.demote-user").click
end

step 'I should see the new trustee' do
  page.should have_css("li[data-role-id='#{@dean_role.id}'] a.promote-user")
end

step 'I should see the new dean' do
  page.should have_css("li[data-role-id='#{@trustee_role.id}'] a.demote-user")
end

step 'I try to promote a user' do
  visit(users_path)
end

step 'I should not see promotion links' do
  page.should_not have_css(".demote-user")
  page.should_not have_css(".promote-user")
end
