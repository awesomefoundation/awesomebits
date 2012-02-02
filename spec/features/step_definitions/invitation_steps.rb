step 'I invite a new trustee to the :name chapter' do |name|
  @chapter = Factory(:chapter, :name => name)
  visit projects_path
  click_link("Invite a trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  select(@chapter.name, :from => "Chapter")
  @invitation_address = FactoryGirl.generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I invite a new trustee to a different chapter' do |name|
  @chapter = FactoryGirl.create(:chapter)
  visit projects_path
  click_link("Invite a trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  select(@chapter.name, :from => "Chapter")
  @invitation_address = FactoryGirl.generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I try to invite a new trustee to my chapter' do |name|
  visit new_invitation_path
end

step 'I invite a new trustee to my chapter' do |name|
  visit projects_path
  click_link("Invite a trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  select(@current_chapter.name, :from => "Chapter")
  @invitation_address = FactoryGirl.generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
end

step 'I try to invite a new trustee to a chapter I am not dean of' do
  @inaccessible_chapter = FactoryGirl.create(:chapter)
  visit new_invitation_path
  select(@inaccessible_chapter.name, :from => "Chapter")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  fill_in("Email", :with => FactoryGirl.generate(:email))
  click_button("Invite")
end

steps_for :dean do
  step 'I am unable to invite them' do
    page.should have_css(".error:contains('You cannot invite to this chapter.')")
  end
end

steps_for :trustee do
  step 'I am unable to invite them' do
    page.should have_css("#flash #flash_notice:contains('You do not have permission to invite others.')")
  end
end

step 'that person should get an invitation email' do
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

step 'they should get another email welcoming them' do
  user = User.find_by_email(@invitation_address)
  user.should_not be_nil
  deliveries = ActionMailer::Base.deliveries.select do |email|
    email.subject =~ /Welcome/ && email.to.include?(@invitation_address)
  end
  deliveries.should have(1).item
end
