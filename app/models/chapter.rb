class Chapter < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :roles
  has_many :users, :through => :roles
  has_many :projects
  has_many :winning_projects, :class_name => "Project", :conditions => "funded_on IS NOT NULL"
  has_many :invitations

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :country
  validates_presence_of :slug
  validates_uniqueness_of :name

  attr_accessible :name, :twitter_url, :facebook_url, :blog_url, :rss_feed_url, :description,
                  :country, :extra_question_1, :extra_question_2, :extra_question_3, :slug

  def should_generate_new_friendly_id?
    slug.blank?
  end


  def self.country_count
    select("count(distinct country) as country_count").first.country_count
  end

  def self.visitable
    where("chapters.name != ?", "Any")
  end

  def self.for_display
    select("(case chapters.name when 'Any' then '0 Any' end) as sort_name, chapters.*").
    order("sort_name, chapters.name")
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

  def self.select_data
    where("chapters.name = ?", 'Any') + where("chapters.name != ?", 'Any').order(:name)
  end

  def any_chapter?
    name == "Any"
  end

  def self.current_chapter_for_user(user)
    if user.admin?
      Chapter.first
    else
      user.chapters.first
    end
  end
end
