require 'spec_helper'

describe Invitation do
  context "validations" do
    before{ create(:invitation) }
    it { should belong_to(:inviter) }
    it { should belong_to(:invitee) }
    it { should belong_to(:chapter) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:inviter) }
    it { should validate_presence_of(:chapter_id) }
    it { should validate_uniqueness_of(:email).scoped_to(:chapter_id) }
  end

  context "#save" do
    let(:user) { create(:user) }
    let(:chapter) { create(:chapter) }
    let(:invitation) { build(:invitation, :inviter => user, :chapter => chapter) }
    it 'should not be valid if the inviter cannot invite to this chapter' do
      invitation.should_not be_valid
    end
  end

  context "#send_invitation" do
    let(:invitation) { build(:invitation) }
    let(:fake_mailer) { FakeMailer.new }
    around do |example|
      old_mailer, invitation.mailer = invitation.mailer, fake_mailer
      example.run
      invitation.mailer = old_mailer
    end

    it "sends the invitation email if it hasn't already been accepted" do
      invitation.send_invitation
      fake_mailer.should have_delivered_email(:invite_trustee)
    end
  end

  context "#accept" do
    let(:invitation) { create(:invitation, :first_name => "Joe", :last_name => "Doe") }
    let(:attributes) { {:first_name => "Jane", :password => "12345"} }
    let(:fake_user_factory) { FakeUserFactory.new }
    let(:fake_mailer) { FakeMailer.new }

    it 'creates a user and assigns it to this invitation' do
      invitation.user_factory = fake_user_factory
      invitation.accept(attributes).should be_true
      fake_user_factory.users.should include(invitation.invitee)
    end

    it 'uses the supplied data to override defaults' do
      invitation.user_factory = fake_user_factory
      invitation.accept(attributes).should be_true
      invitation.invitee.first_name.should == "Jane"
    end

    it 'sends an email if the user was created' do
      invitation.user_factory = fake_user_factory
      invitation.mailer = fake_mailer
      invitation.accept(attributes).should be_true
      fake_mailer.should have_delivered_email(:welcome_trustee)
    end

    it 'sends no email if the user was not created' do
      invitation.user_factory = fake_user_factory
      fake_user_factory.fail!
      invitation.mailer = fake_mailer
      invitation.accept(attributes).should_not be_true
      fake_mailer.should_not have_delivered_email(:welcome_trustee)
    end
  end
end
