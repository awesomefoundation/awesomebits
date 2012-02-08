class Chapter < ActiveRecord::Base
  has_many :roles
  has_many :users, :through => :roles
  has_many :projects
  has_many :invitations

  validates_uniqueness_of :name

  attr_accessible :name, :twitter_url, :facebook_url, :blog_url, :rss_feed_url, :description

  def self.invitable_by(user)
    if user.admin?
      where("chapters.name != 'Any'")
    else
      joins(:roles).
        where("roles.name = 'dean'").
        where("roles.user_id = ?", user.id).
        where("chapters.name != 'Any'")
    end
  end
end
