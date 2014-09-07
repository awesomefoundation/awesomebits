step 'I invite a new trustee to the :name chapter' do |name|
  @chapter = FactoryGirl.create(:chapter, :name => name)
  visit projects_path
  click_link("Invite a Trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  select(@chapter.name, :from => "Select a chapter")
  @invitation_address = generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I invite the same trustee to the :name chapter' do |name|
  visit projects_path
  click_link("Invite a Trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  select(@chapter.name, :from => "Select a chapter")
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I invite a new trustee to a different chapter' do |name|
  @chapter = FactoryGirl.create(:chapter)
  visit projects_path
  click_link("Invite a Trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  select(@chapter.name, :from => "Select a chapter")
  @invitation_address = generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I try to invite a new trustee to my chapter anyway' do |name|
  visit new_invitation_path
end

step 'I visit the invitation screen' do
  visit new_invitation_path
end

step 'I should not see a drop down menu with chapters' do
  page.should have_no_content('Select a chapter')
end

step 'I should not see a link to invite other trustees' do
  page.should have_no_css(".admin-panel a:contains('Invite a trustee')")
end

step 'I invite a new trustee to my chapter' do |name|
  visit projects_path
  click_link("Invite a Trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  @invitation_address = generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I try to invite a new trustee to a chapter I am not dean of' do
  @inaccessible_chapter = FactoryGirl.create(:chapter)
  visit new_invitation_path
end

steps_for :dean do
  step 'I am unable to invite them to that chapter' do
    page.should have_no_css("select[name='invitation[chapter_id]'] option:contains('#{@inaccessible_chapter.name}')")
  end
end

steps_for :trustee do
  step 'I am unable to invite them' do
    page.should have_css("#flash #flash_notice:contains('You do not have permission to invite others.')")
  end
end

step 'the email backlog has been cleared' do
  ActionMailer::Base.deliveries.clear
end

step 'that person should get an(other) invitation email' do
  invitation = Invitation.find_by_email(@invitation_address)
  invitation.should_not be_nil
  deliveries = ActionMailer::Base.deliveries.select do |email|
    email.subject =~ /invited/ && email.to.include?(@invitation_address)
  end
  deliveries.should have(1).item
  @invitation_email = deliveries.first
end

step 'they accept the invitation' do
  accept_url = @invitation_email.body.to_s.scan(%r{https?://\S*}).first
  visit(accept_url)
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  fill_in("Password", :with => "12345")
  click_button("Accept the invitation!")
end

step 'the trustee tries to accept the invitation yet again' do
  step 'they accept the invitation'
end

step 'they should get (yet) another email welcoming them' do
  user = User.find_by_email(@invitation_address)
  user.should_not be_nil
  deliveries = ActionMailer::Base.deliveries.select do |email|
    email.subject =~ /Welcome/ && email.to.include?(@invitation_address)
  end
  deliveries.should have(1).item
end
