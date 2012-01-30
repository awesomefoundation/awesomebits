step "I am logged in as an admin" do
  @current_user = Factory(:user, :admin => true, :password => "12345")
  visit new_sessions_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I log back in" do
  visit new_sessions_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I am logged in as a dean" do
  @current_chapter = FactoryGirl.create(:chapter)
  @current_user = FactoryGirl.create(:user, :password => "12345")
  @current_role = FactoryGirl.create(:role,
                                     :user => @current_user,
                                     :chapter => @current_chapter,
                                     :name => "dean")
  visit new_sessions_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I am logged in as a trustee" do |name|
  @current_chapter = FactoryGirl.create(:chapter)
  @current_user = FactoryGirl.create(:user, :password => "12345")
  @current_role = FactoryGirl.create(:role,
                                     :user => @current_user,
                                     :chapter => @current_chapter,
                                     :name => "trustee")
  visit new_sessions_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end
