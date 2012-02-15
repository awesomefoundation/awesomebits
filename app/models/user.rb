class User < ActiveRecord::Base
  include Clearance::User
  attr_accessible :first_name, :last_name, :email, :bio, :url, :twitter_username, :facebook_url, :linkedin_url, :last_viewed_chapter_id

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :encrypted_password

  validates_uniqueness_of :email

  has_many :roles
  has_many :chapters, :through => :roles

  has_many :votes
  has_many :projects, :through => :votes

  def self.deans_first
    joins(:chapters).order("roles.name, users.last_name")
  end

  def self.including_role
    joins(:chapters).select('users.*, roles.name as role')
  end

  def name
    [first_name, last_name].map(&:to_s).join(" ").strip
  end

  def can_manage_chapter?(chapter)
    admin? || roles.can_manage_chapter?(chapter)
  end

  def trustee?
    admin? || roles.any?(&:trustee?)
  end

  def gravatar_url
    Gravatar.new(email).url
  end

  def can_manage_permissions?
    admin?
  end

  def can_create_chapters?
    admin?
  end

  def can_invite?
    admin? || roles.can_invite?
  end

  def can_invite_to_chapter?(chapter)
    admin? || roles.can_invite_to_chapter?(chapter)
  end

  def can_view_finalists_for?(chapter)
    admin? || roles.can_view_finalists_for?(chapter)
  end

  def can_mark_winner?(project)
    admin? || roles.can_mark_winner?(project)
  end

  def can_edit_profile?(user_id)
    admin? || id == user_id.to_i
  end

  def mark_last_viewed_chapter(chapter_id)
    update_attributes(:last_viewed_chapter_id => chapter_id)
  end

  def set_password(new_password)
    unless new_password.blank?
      self.password = new_password
    end
  end

end
