step "I am logged in as an admin" do
  @current_user = Factory(:user, :admin => true, :password => "12345")
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I log back in" do
  visit sign_in_path
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
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I am logged in as a dean for only one chapter" do
  @current_chapter = FactoryGirl.create(:chapter)
  @current_user = FactoryGirl.create(:user, :password => "12345")
  @current_role = FactoryGirl.create(:role,
                                     :user => @current_user,
                                     :chapter => @current_chapter,
                                     :name => "dean")
  visit sign_in_path
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
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end
