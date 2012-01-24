step "I am logged in as an admin" do
  @user = Factory(:user, :admin => true, :password => "12345")
  visit new_sessions_path
  fill_in("Email", :with => @user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end
