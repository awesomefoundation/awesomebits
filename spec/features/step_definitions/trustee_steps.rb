step "the trustee can log in" do
  visit root_path
  click_link("Sign out")
  fill_in("Email", :with => "new_trustee@example.com")
  fill_in("Password", :with => "12345")
  click_button("Sign in")
  page.should have_css("body.home")
  page.should have_no_css("body.clearance-sessions")
end
