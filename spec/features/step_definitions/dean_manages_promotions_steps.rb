step "there is a :role_name for my chapter in the system" do |role_name|
  instance_variable_set("@#{role_name}_role", FactoryGirl.create(:role, :name => role_name, :chapter => @current_chapter))
  instance_variable_set("@#{role_name}", instance_variable_get("@#{role_name}_role").user)
  instance_variable_set("@#{role_name}_chapter", instance_variable_get("@#{role_name}_role").chapter)
end

step 'I remove trustee from my chapter' do
  visit chapter_users_path(@current_chapter)
  accept_confirm { click_link("Remove") }
  page.evaluate_script('window.confirm = function() { return true; }')
end
