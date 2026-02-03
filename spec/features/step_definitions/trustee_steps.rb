step "there is a trustee in the system" do
  @trustee_role     = FactoryBot.create(:role, :name => 'trustee')
  @trustee          = @trustee_role.user
  @trustee_chapter  = @trustee_role.chapter
end

step "there is another trustee in the system" do
  @another_trustee_role    = FactoryBot.create(:role, :name => "trustee")
  @another_trustee         = @another_trustee_role.user
  @another_trustee_chapter = @another_trustee_role.chapter
end

step "I edit that trustee's email address" do
  visit(root_path)
  click_link "Dashboard"
  click_link "View all Users"
  within("*[data-user-id='#{@trustee.id}']") do
    click_link "Edit"
  end
  fill_in("Email", with: "new@email.addr")
  click_button("Update User")
end

step "I should see the change reflected in the list of all users" do
  visit(root_path)
  click_link "Dashboard"
  click_link "View all Users"
  expect(page).to have_css("*[data-user-id='#{@trustee.id}'] td:contains('new@email.addr')")
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
  expect(page).to have_selector("h2", :text => "#{@updated_trustee_first_name} #{@updated_trustee_last_name}")
end

step "I am on the projects page of my last viewed chapter" do
  expect(page).to have_selector("a.chapter-selection", :text => @current_chapter.name)
end

step "I should see an update user permission error" do
  expect(page).to have_content("You do not have permission to modify this account.")
end

step "I should see an error about not having a chapter" do
  expect(page).to have_content("Your account is not associated with any chapters.")
end

step "I update my password" do
  @updated_password = "BaxterRocks"
  visit chapter_projects_path(@current_chapter)
  click_link("Edit My Profile")
  fill_in("user_new_password", :with => @updated_password)
  click_button("Update User")
end

step "I should be able to log in with updated password" do
  visit sign_in_path
  fill_in("Email",    :with => @current_user.email)
  fill_in("Password", :with => @updated_password)
  click_button("Sign in")
  expect(page).to have_selector("h2", :text => "#{@current_user.first_name} #{@current_user.last_name}")
end
