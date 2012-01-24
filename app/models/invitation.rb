class Invitation < ActiveRecord::Base
  belongs_to :inviter, :class_name => "User"
  belongs_to :invitee, :class_name => "User"
  belongs_to :chapter

  validates_presence_of :email
end
