require "texticle/searchable"

class Project < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :hidden_by_user, class_name: "User"
  has_many :votes
  has_many :users, :through => :votes
  has_many :photos, :order => "photos.sort_order asc, photos.id asc"

  attr_accessible :name, :title, :url, :email, :phone, :about_me, :about_project,
                  :chapter_id, :extra_question_1, :extra_question_2, :extra_question_3,
                  :extra_answer_1, :extra_answer_2, :extra_answer_3,
                  :new_photos, :photo_order, :rss_feed_url, :use_for_money, :funded_on, :funded_description,
                  :new_photo_direct_upload_urls,
                  :hidden_by_user_id, :hidden_reason, :hidden_at

  before_validation UrlNormalizer.new(:url, :rss_feed_url)

  validates           :url, :rss_feed_url, :url => true, :allow_blank => true
  validates_length_of :url, :rss_feed_url, :maximum => 255

  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :email
  validates_presence_of :about_me
  validates_presence_of :about_project
  validates_presence_of :use_for_money
  validates_presence_of :chapter_id

  delegate :name, :to => :chapter, :prefix => true

  before_save :ensure_funded_description

  # For dependency injection
  cattr_accessor :mailer
  self.mailer = ProjectMailer

  # specify the default fields on which full text search will be performed
  extend Searchable(:name, :title, :about_me, :about_project, :use_for_money,
                    :extra_answer_1, :extra_answer_2, :extra_answer_3)

  def self.winner_count
    where("funded_on IS NOT NULL").count
  end

  def self.visible_to(user)
    joins(:chapter).
      joins("LEFT OUTER JOIN roles ON roles.chapter_id = chapters.id").
      where("roles.user_id = #{user.id} OR chapters.name = 'Any'")
  end

  def self.voted_for_by_members_of(chapter)
    joins(:users => :chapters).where("chapters.id = #{chapter.id} OR chapters.name = 'Any'")
  end

  def self.during_timeframe(start_date, end_date)
    # FIXME the database stores dates in UTC, whereas we parse the dates
    # provided in the local zone. This can result in mismatches when the
    # overlap crosses midnight.
    start_date = 100.years.ago.strftime('%Y-%m-%d') if start_date.blank?
    end_date   = Time.zone.now.strftime('%Y-%m-%d') if end_date.blank?

    where(
      "projects.created_at > ? AND projects.created_at < ?",
      Time.zone.parse(start_date),
      Time.zone.parse(end_date) + 1.day
    )
  end

  def self.by_vote_count
    select("projects.chapter_id, projects.id, projects.title, COUNT(votes.project_id) as vote_count").
      group("projects.id, projects.title, votes.project_id").
      joins(:users).
      order("vote_count DESC")
  end

  def self.winners
    where("funded_on IS NOT NULL")
  end

  def self.recent_winners
    subquery = select("DISTINCT ON (chapter_id) projects.*").where("projects.funded_on IS NOT NULL").order(:chapter_id, :funded_on).reverse_order
    select("*").from("(#{subquery.to_sql}) AS distinct_chapters").order(:funded_on).reverse_order
  end

  def self.csv_export(projects)
    CSV.generate do |csv|
      csv << attributes_for_export
      projects.each do |project|
        csv << project.to_a
      end
    end
  end

  def self.attributes_for_export
    %w(name title about_project use_for_money about_me url email phone chapter_name id created_at funded_on extra_question_1 extra_answer_1 extra_question_2 extra_answer_2 extra_question_3 extra_answer_3 rss_feed_url)
  end

  def to_a
    self.class.attributes_for_export.collect { |attr| send(attr).to_s }
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def shortlisted_by?(user)
    users.include?(user)
  end

  def deliver_winning_email
    mailer.winner(self).deliver
  end

  def declare_winner!(new_chapter = nil)
    self.funded_on = Date.today
    if new_chapter.present?
      self.chapter = new_chapter
    end
    save
  end

  def revoke_winner!
    self.funded_on = nil
    save
  end

  def winner?
    funded_on.present?
  end

  def in_any_chapter?
    chapter.any_chapter?
  end

  def photo_order
    photos.map(&:id).join(" ")
  end

  def photo_order=(order_string)
    ids = order_string.split(" ").map(&:to_i)
    ordered_photos = ids.map do |id|
      photos.find(id)
    end
    ordered_photos.each_with_index{|photo, i| photo.update_attribute(:sort_order, i) }
    self.photos = ordered_photos
  end

  def new_photos=(photos)
    photos.each do |photo|
      if photo.present?
        new_photo = self.photos.build(:image => photo)
        if persisted?
          new_photo.save
        end
      end
    end
  end

  def new_photo_direct_upload_urls=(urls)
    urls.each do |url|
      if url.present?
        new_photo = self.photos.build(:direct_upload_url => url)
        if persisted?
          new_photo.save
        end
      end
    end
  end

  def display_images
    if photos.empty?
      [Photo.new]
    else
      photos
    end
  end

  def primary_image
    display_images.first
  end

  def has_images?
    photos.present?
  end

  def save
    was_new_record = new_record?
    saved = super
    if saved && was_new_record
      ProjectMailerJob.new.async.perform(self)
    end
    saved
  end

  def extra_question(num)
    (question = read_attribute("extra_question_#{num}".to_sym)) && question.present? ? question : nil
  end

  def extra_answer(num)
    (answer = read_attribute("extra_answer_#{num}".to_sym)) && answer.present? ? answer : nil
  end

  def hide!(reason, user)
    update_attributes(
      hidden_reason: reason,
      hidden_by_user_id: user.id,
      hidden_at: Time.zone.now
    )
  end

  def unhide!
    update_attributes(
      hidden_reason: nil,
      hidden_by_user_id: nil,
      hidden_at: nil
    )
  end

  def hidden?
    !!hidden_at
  end

  protected

  # before save
  def ensure_funded_description
    if winner?
      self.funded_description ||= about_project
    end

    true
  end
end
