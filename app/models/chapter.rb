class Chapter < ApplicationRecord
  EXTRA_QUESTIONS_COUNT = 3
  ANY_CHAPTER_NAME = "Any"

  DEFAULT_SUBMISSION_RESPONSE_EMAIL = <<-EOT
We wanted to send you this (automated) email to let you know that we have received your Awesome Foundation application. Your application will be considered at the specified chapter's next deliberation meeting.

Unfortunately, we are not able to personally respond to all of our applicants, but be sure to follow our Twitter account at http://twitter.com/awesomefound for information about grants from all of our chapters.

Thanks for your interest in the Awesome Foundation!
EOT

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :roles
  has_many :users, :through => :roles
  has_many :projects
  has_many :winning_projects, -> { where.not(funded_on: nil).order(funded_on: :desc) }, class_name: "Project"
  has_many :invitations

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :country
  validates_presence_of :slug
  validates_uniqueness_of :name

  validates_format_of :slug, :with => /\A[a-z0-9-]+\Z/

  def self.any_chapter
    find_by(name: ANY_CHAPTER_NAME)
  end

  def self.country_count
    where(arel_table[:country].not_eq("Worldwide")).select(:country).distinct.count
  end

  def self.visitable
    where.not(name: ANY_CHAPTER_NAME)
  end

  def self.active
    where(:inactive_at => nil)
  end

  def self.for_display
    select("(case chapters.name when '#{ANY_CHAPTER_NAME}' then '0 #{ANY_CHAPTER_NAME}' end) as sort_name, chapters.*").
    order("sort_name, chapters.name")
  end

  def self.invitable_by(user)
    if user.admin?
      where.not(name: ANY_CHAPTER_NAME)
    else
      joins(:roles).
        where("roles.name = 'dean'").
        where("roles.user_id = ?", user.id).
        where.not(name: ANY_CHAPTER_NAME)
    end
  end

  # Scope can be :active or :all
  def self.select_data(scope = :active)
    countries = [OpenStruct.new(:name => "Any Chapter", :chapters => where(name: ANY_CHAPTER_NAME))]

    selection = scope == :all ? visitable : active.visitable

    selection.sort_by(&CountrySortCriteria.new(COUNTRY_PRIORITY)).each do |chapter|
      if countries.last.try(:name) != chapter.country
        countries.push OpenStruct.new(:name => chapter.country, :chapters => [])
      end

      countries.last.chapters.push chapter
    end

    countries
  end

  def self.current_chapter_for_user(user)
    if user.admin?
      user.chapters.first || Chapter.first
    else
      user.chapters.first
    end
  end

  def any_chapter?
    name == ANY_CHAPTER_NAME
  end

  def global?
    country == "Worldwide"
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def display_name
    if inactive?
      "#{self[:name]} (#{I18n.t('word.inactive')})"
    else
      self[:name]
    end
  end

  def time_zone
    self[:time_zone] || 'UTC'
  end

  def grant_amount_dollars
    1000.00
  end

  def grant_frequency
    I18n.t('word.monthly')
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
