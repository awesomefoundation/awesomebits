step "I am logged in as an admin" do
  @current_user = FactoryBot.create(:user, :admin => true, :password => "12345")
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
  @current_chapter = FactoryBot.create(:chapter)
  @current_user = FactoryBot.create(:user, :password => "12345")
  @current_role = FactoryBot.create(:role,
                         :user => @current_user,
                         :chapter => @current_chapter,
                         :name => "dean")
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I am logged in as a dean for 2 chapters" do
  @current_chapter = FactoryBot.create(:chapter)
  @other_chapter = FactoryBot.create(:chapter)
  @current_user = FactoryBot.create(:user, :password => "12345")
  @current_role = FactoryBot.create(:role,
                         :user => @current_user,
                         :chapter => @current_chapter,
                         :name => "dean")
  @other_role = FactoryBot.create(:role,
                       :user => @current_user,
                       :chapter => @other_chapter,
                       :name => "dean")
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I am logged in as a dean for only one chapter" do
  @current_chapter = FactoryBot.create(:chapter)
  @current_user = FactoryBot.create(:user, :password => "12345")
  @current_role = FactoryBot.create(:role,
                         :user => @current_user,
                         :chapter => @current_chapter,
                         :name => "dean")
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I am logged in as a trustee" do |name = Faker::Name.name|
  @current_chapter = FactoryBot.create(:chapter)
  @current_user = FactoryBot.create(:user, :password => "12345")
  @current_role = FactoryBot.create(:role,
                         :user => @current_user,
                         :chapter => @current_chapter,
                         :name => "trustee")
  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "the trustee can log in" do
  visit root_path
  click_link("Sign in")
  fill_in("Email", :with => @invitation_address)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
  expect(page).to have_css("body.projects")
  expect(page).to have_no_css("body.home")
  expect(page).to have_no_css("body.clearance-sessions")
end

step "I log in as a trustee with no chapter" do
  @current_user = FactoryBot.create(:user, :password => "12345")

  visit sign_in_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => "12345")
  click_button("Sign in")
end

step "I log out" do
  click_link("Sign out")
  expect(page).to have_content(/Sign in/i)
end
