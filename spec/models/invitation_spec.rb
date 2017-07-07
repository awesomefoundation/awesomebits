require 'spec_helper'

describe Invitation do
  context "validations" do
    before{ FactoryGirl.create(:invitation) }
    it { is_expected.to belong_to(:inviter) }
    it { is_expected.to belong_to(:invitee) }
    it { is_expected.to belong_to(:chapter) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:inviter) }
    it { is_expected.to validate_presence_of(:chapter_id) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:chapter_id) }
  end

  context "#save" do
    let(:user) { FactoryGirl.create(:user) }
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:invitation) { FactoryGirl.build(:invitation, :inviter => user, :chapter => chapter) }
    it 'should not be valid if the inviter cannot invite to this chapter' do
      expect(invitation).not_to be_valid
    end
  end

  context "#send_invitation" do
    let(:invitation) { FactoryGirl.build(:invitation) }
    let(:fake_mailer) { FakeMailer.new }
    around do |example|
      old_mailer, invitation.mailer = invitation.mailer, fake_mailer
      example.run
      invitation.mailer = old_mailer
    end

    it "sends the invitation email if it hasn't already been accepted" do
      invitation.send_invitation
      expect(fake_mailer).to have_delivered_email(:invite_trustee)
    end
  end

  context "#accept" do
    let(:invitation) { FactoryGirl.create(:invitation, :first_name => "Joe", :last_name => "Doe") }
    let(:attributes) { {:first_name => "Jane", :password => "12345"} }
    let(:fake_user_factory) { FakeUserFactory.new }
    let(:fake_mailer) { FakeMailer.new }

    it 'creates a user and assigns it to this invitation' do
      invitation.user_factory = fake_user_factory
      expect(invitation.accept(attributes)).to be_truthy
      expect(fake_user_factory.users).to include(invitation.invitee)
    end

    it 'uses the supplied data to override defaults' do
      invitation.user_factory = fake_user_factory
      expect(invitation.accept(attributes)).to be_truthy
      expect(invitation.invitee.first_name).to eq("Jane")
    end

    it 'sends an email if the user was created' do
      invitation.user_factory = fake_user_factory
      invitation.mailer = fake_mailer
      expect(invitation.accept(attributes)).to be_truthy
      expect(fake_mailer).to have_delivered_email(:welcome_trustee)
    end

    it 'sends no email if the user was not created' do
      invitation.user_factory = fake_user_factory
      fake_user_factory.fail!
      invitation.mailer = fake_mailer
      expect(invitation.accept(attributes)).not_to be_truthy
      expect(fake_mailer).not_to have_delivered_email(:welcome_trustee)
    end
  end
end
