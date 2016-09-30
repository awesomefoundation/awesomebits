class Invitation < ActiveRecord::Base
  belongs_to :inviter, :class_name => "User"
  belongs_to :invitee, :class_name => "User"
  belongs_to :chapter

  validates_presence_of :email
  validates_presence_of :chapter_id
  validates_presence_of :inviter
  validates_uniqueness_of :email, :scope => :chapter_id
  validate :ensure_inviter_can_invite_to_chapter

  attr_accessible :email, :first_name, :last_name, :chapter_id

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
      self.accepted = true
      self.save
    else
      unless factory.errors.blank?
        factory.errors.each do |key, error|
          self.errors[key] = error
        end
      end
      false
    end
  end

  def send_invitation
    mailer.invite_trustee(self).deliver
  end

  def ensure_inviter_can_invite_to_chapter
    unless inviter && inviter.can_invite_to_chapter?(chapter)
      errors.add(:chapter_id, "You cannot invite to this chapter.")
    end
  end
end
