class Invitation < ActiveRecord::Base
  belongs_to :inviter, :class_name => "User"
  belongs_to :invitee, :class_name => "User"
  belongs_to :chapter

  validates_presence_of :email
  validates_presence_of :chapter
  attr_accessible :email

  cattr_accessor :mailer
  self.mailer = InvitationMailer

  cattr_accessor :user_factory
  self.user_factory = UserFactory

  def accept(new_attributes)
    factory = user_factory.new(:first_name => new_attributes[:first_name] || first_name,
                               :last_name => new_attributes[:last_name] || last_name,
                               :password => new_attributes[:password],
                               :email => email,
                               :chapter => chapter)

    if factory.create
      mailer.welcome_trustee(self).deliver
      self.invitee = factory.user
    end
  end

  def save
    was_new_record = new_record?
    saved = super
    if was_new_record && saved
      mailer.invite_trustee(self).deliver
    end
    saved
  end
end
