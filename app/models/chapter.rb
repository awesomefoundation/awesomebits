class Chapter < ActiveRecord::Base
  has_many :roles
  has_many :users, :through => :roles
  has_many :projects
  has_many :winning_projects, :class_name => "Project", :conditions => "funded_on IS NOT NULL"
  has_many :invitations

  validates_presence_of :name
  validates_presence_of :description
  validates_uniqueness_of :name

  attr_accessible :name, :twitter_url, :facebook_url, :blog_url, :rss_feed_url, :description,
                  :extra_question_1, :extra_question_2, :extra_question_3

  def self.visitable
    where("chapters.name != ?", "Any")
  end

  def self.alphabetically
    order(:name)
  end

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

  def any_chapter?
    name == "Any"
  end
end
