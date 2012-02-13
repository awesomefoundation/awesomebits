step "the trustee can log in" do
  visit root_path
  click_link("Sign out")
  fill_in("Email", :with => @invitation_address)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
  page.should have_css("body.projects")
  page.should have_no_css("body.home")
  page.should have_no_css("body.clearance-sessions")
end

step "there is a trustee in the system" do
  @trustee_role     = Factory(:role, :name => 'trustee')
  @trustee          = @trustee_role.user
  @trustee_chapter  = @trustee_role.chapter
end
