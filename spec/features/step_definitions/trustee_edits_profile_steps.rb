step "there is a trustee in the system" do
  @trustee_role     = Factory(:role, :name => 'trustee')
  @trustee          = @trustee_role.user
  @trustee_chapter  = @trustee_role.chapter
end

step "there is another trustee in the system" do
  @another_trustee_role    = Factory(:role, :name => "trustee")
  @another_trustee         = @another_trustee_role.user
  @another_trustee_chapter = @another_trustee_role.chapter
end

step "I try to change the other trustees information" do
  visit edit_user_path(@another_trustee)
end

step "I change my profile information" do
  @updated_trustee_email      = "poppa.burgundy@channel4news.org"
  @updated_trustee_first_name = "Ron"
  @updated_trustee_last_name  = "Burgundy"
  visit chapter_projects_path(@current_chapter)
  click_link("Edit My Profile")
  fill_in("Email",      :with => @updated_trustee_email)
  fill_in("First name", :with => @updated_trustee_first_name)
  fill_in("Last name",  :with => @updated_trustee_last_name)
  click_button("Update User")
end

step "my profile is updated" do
  page.should have_selector("h2", :text => "#{@updated_trustee_first_name} #{@updated_trustee_last_name}")
end

step "I amon on the projects page for my last viewed chapter" do
  page.should have_selector("a.chapter-selection", :text => @current_chapter)
end

step "I should see an update user permission error" do
  page.should have_content("You do not have permission to modify this account.")
end

step "I update my password" do
  @updated_password = "BaxterRocks"
  visit chapter_projects_path(@current_chapter)
  click_link("Edit My Profile")
  fill_in("New password", :with => @updated_password)
  click_button("Update User")
end

step "I should be able to log in with updated password" do
  fill_in("Email",    :with => @current_user.email)
  fill_in("Password", :with => @updated_password)
  click_button("Sign in")
  page.should have_selector("h2", :text => "#{@current_user.first_name} #{@current_user.last_name}")
end
