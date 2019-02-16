class Chapter < ActiveRecord::Base
  EXTRA_QUESTIONS_COUNT = 3

  DEFAULT_SUBMISSION_RESPONSE_EMAIL = <<-EOT
We wanted to send you this (automated) email to let you know that we have
received your Awesome Foundation application. Your application will be
considered at the specified chapter's next deliberation meeting.

Unfortunately, we are not able to personally respond to all of our
applicants, but be sure to follow our Twitter account at
http://twitter.com/awesomefound for information about grants from all
of our chapters.

Thanks for your interest in the Awesome Foundation!
EOT

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :roles
  has_many :users, :through => :roles
  has_many :projects
  has_many :winning_projects, :class_name => "Project", :conditions => "funded_on IS NOT NULL", :order => "funded_on DESC"
  has_many :invitations

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :country
  validates_presence_of :slug
  validates_uniqueness_of :name

  validates_format_of :slug, :with => /\A[a-z0-9-]+\Z/

  attr_accessible :name, :twitter_url, :facebook_url, :blog_url, :rss_feed_url, :description,
                  :country, :extra_question_1, :extra_question_2, :extra_question_3, :slug,
                  :email_address, :time_zone, :inactive, :locale, :submission_response_email,
                  :hide_trustees, :instagram_url

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def self.country_count
    where(arel_table[:country].not_eq("Worldwide")).select(:country).uniq.count
  end

  def self.visitable
    where("chapters.name != ?", "Any")
  end

  def self.active
    where(:inactive_at => nil)
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

  # Scope can be :active or :all
  def self.select_data(scope = :active)
    countries = [OpenStruct.new(:name => "Any Chapter", :chapters => where("chapters.name = ?", "Any"))]

    selection = scope == :all ? visitable : active.visitable

    selection.sort_by(&CountrySortCriteria.new(COUNTRY_PRIORITY)).each do |chapter|
      if countries.last.try(:name) != chapter.country
        countries.push OpenStruct.new(:name => chapter.country, :chapters => [])
      end

      countries.last.chapters.push chapter
    end

    countries
  end

  def any_chapter?
    name == "Any"
  end

  def self.current_chapter_for_user(user)
    if user.admin?
      user.chapters.first || Chapter.first
    else
      user.chapters.first
    end
  end

  def name
    if inactive?
      "#{self[:name]} (#{I18n.t('word.inactive')})"
    else
      self[:name]
    end
  end

  def time_zone
    self[:time_zone] || 'UTC'
  end

  def inactive
    inactive_at.present?
  end

  def inactive?
    inactive
  end

  def active?
    inactive_at.nil?
  end

  def inactive=(bool)
    if [ 1, '1', true, 'true' ].include? bool
      self.inactive_at = Time.zone.now
    else
      self.inactive_at = nil
    end
  end
end
