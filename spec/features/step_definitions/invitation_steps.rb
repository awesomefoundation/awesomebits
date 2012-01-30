step 'I invite a new trustee to the :name chapter' do |name|
  ActionMailer::Base.deliveries.clear
  @chapter = Factory(:chapter, :name => name)
  visit chapter_url(@chapter)
  click_link("Invite new trustee")
  fill_in("First name", :with => "Joe")
  fill_in("Last name", :with => "Schmoe")
  @invitation_address = FactoryGirl.generate(:email)
  fill_in("Email", :with => @invitation_address)
  click_button("Invite")
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
