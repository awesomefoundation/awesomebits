step "there is a trustee for my chapter in the system" do
  @trustee_role     = create(:role, :name => 'trustee', :chapter => @current_chapter)
  @trustee          = @trustee_role.user
  @trustee_chapter  = @trustee_role.chapter
end

step 'I remove trustee from my chapter' do
  visit chapter_users_path(@current_chapter)
  save_and_open_page
  click_link("Remove")
  page.evaluate_script('window.confirm = function() { return true; }')
end
