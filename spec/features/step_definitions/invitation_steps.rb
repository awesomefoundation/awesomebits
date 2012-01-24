step 'I invite a new trustee to the :name chapter' do |name|
  @chapter = Factory(:chapter, :name => name)
  visit chapter_url(@chapter)
  click_link("Invite new trustee")
  fill_in("Email", :with => "new_trustee@example.com")
  click_button("Invite")
end

step 'that person should get an invitation email' do
  invitation = Invitation.find_by_email("new_trustee@example.com")
  invitation.should_not be_nil
  deliveries = ActionMailer::Base.deliveries.select do |email|
    email.subject =~ /Invited/
  end
  deliveries.length.should have(1).item
  @invitation_email = deliveries.first
end

step 'they accept the invitation' do
  accept_url = @invitation_email.body.scan(%r{https?://[^ ]*})
  visit(accept_url)
end
