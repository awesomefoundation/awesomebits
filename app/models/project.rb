require "textacular/searchable"

class Project < ApplicationRecord
  MAX_PHOTOS = 5

  attr_accessor :photo_order
  attr_accessor :photo_ids_to_delete

  belongs_to :chapter
  belongs_to :hidden_by_user, class_name: "User", optional: true
  has_many :comments
  has_many :votes
  has_many :users, :through => :votes
  has_many :photos, -> { merge(Photo.sorted) }
  has_many :real_photos, -> { merge(Photo.image_files.sorted) }, class_name: "Photo"
  has_one  :primary_photo, -> { merge(Photo.image_files.sorted) }, class_name: "Photo"

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
  before_save :update_photo_order
  before_save :delete_photos

  # For dependency injection
  cattr_accessor :mailer
  self.mailer = ProjectMailer

  # specify the default fields on which full text search will be performed
  extend Searchable(:name, :title, :email, :about_me, :about_project, :use_for_money,
                    :extra_answer_1, :extra_answer_2, :extra_answer_3)

  scope :public_search, lambda { |query| search({ name: query, title: query, funded_description: query, url: query }, false) }

  accepts_nested_attributes_for :photos, allow_destroy: true

  def self.winner_count
    where("funded_on IS NOT NULL").count
  end

  def self.visible_to(user)
    joins(:chapter).
      joins("LEFT OUTER JOIN roles ON roles.chapter_id = chapters.id").
      where("roles.user_id = #{user.id} OR chapters.name = ?", Chapter::ANY_CHAPTER_NAME)
  end

  def self.with_votes_for_chapter(c)
    where(id: Vote.where(chapter: c).select(:project_id))
  end

  def self.with_votes_by_members_of_chapter(c)
    joins(:users).merge(User.where(id: c.users.select(:id)))
  end

  def self.voted_for_by_members_of(chapter)
    joins(:users => :chapters).where("chapters.id = ? OR chapters.name = ?", chapter.id, Chapter::ANY_CHAPTER_NAME)
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

  def self.by_vote_count(sort: nil)
    order = case sort
            when "date" then "projects.created_at DESC, vote_count DESC"
            when "title" then "projects.title ASC, vote_count DESC"
            else "vote_count DESC, projects.created_at ASC"
            end

    select("projects.chapter_id, projects.id, projects.title, projects.funded_on, COUNT(votes.project_id) as vote_count, projects.created_at").
      group("projects.id, projects.title, votes.project_id").
      joins(:users).
      order(order)
  end

  def self.winners
    where.not(funded_on: nil)
  end

  def self.recent_winners
    subquery = select("DISTINCT ON (chapter_id) projects.*").where("projects.funded_on IS NOT NULL").order(:chapter_id, :funded_on).reverse_order
    select("*").from("(#{subquery.to_sql}) AS distinct_chapters").order("distinct_chapters.funded_on").reverse_order
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
    %w(name title about_project use_for_money about_me url email phone chapter_name id created_at funded_on extra_question_1 extra_answer_1 extra_question_2 extra_answer_2 extra_question_3 extra_answer_3 rss_feed_url hidden_at hidden_reason)
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
    mailer.winner(self).deliver_now
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

  def display_images
    if real_photos.empty?
      [Photo.new]
    else
      real_photos
    end
  end

  def primary_image
    primary_photo || Photo.new
  end

  def has_images?
    real_photos.present?
  end

  def save
    was_new_record = new_record?
    saved = super
    if saved && was_new_record
      ProjectMailerJob.perform_async(self)
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
    update(
      hidden_reason: reason,
      hidden_by_user_id: user.id,
      hidden_at: Time.zone.now
    )
  end

  def unhide!
    update(
      hidden_reason: nil,
      hidden_by_user_id: nil,
      hidden_at: nil
    )
  end

  def hidden?
    !!hidden_at
  end

  def set_request_metadata(server_data, client_data_json = nil)
    client_data = parse_and_sanitize_client_data(client_data_json)

    self.metadata = {
      ip_address: server_data[:ip_address],
      user_agent: server_data[:user_agent]&.truncate(500),
      referrer: server_data[:referrer]&.truncate(500),
      time_on_page_ms: client_data[:time_on_page_ms],
      timezone: client_data[:timezone],
      screen_resolution: client_data[:screen_resolution],
      form_interactions_count: client_data[:form_interactions_count],
      keystroke_count: client_data[:keystroke_count],
      paste_count: client_data[:paste_count]
    }.compact
  end

  private

  def parse_and_sanitize_client_data(client_data_json)
    return {} unless client_data_json.present?

    begin
      raw_data = JSON.parse(client_data_json)
      {
        time_on_page_ms: sanitize_integer(raw_data["time_on_page_ms"]),
        timezone: sanitize_string(raw_data["timezone"], 50),
        screen_resolution: sanitize_string(raw_data["screen_resolution"], 20),
        form_interactions_count: sanitize_integer(raw_data["form_interactions_count"]),
        keystroke_count: sanitize_integer(raw_data["keystroke_count"]),
        paste_count: sanitize_integer(raw_data["paste_count"])
      }
    rescue JSON::ParserError => e
      Rails.logger.warn "Invalid client_metadata JSON: #{e.message}"
      {}
    end
  end

  def sanitize_integer(value)
    return nil unless value.present?
    Integer(value) rescue nil
  end

  def sanitize_string(value, max_length)
    return nil unless value.present?
    value.to_s.truncate(max_length)
  end

  protected

  # before save
  def ensure_funded_description
    if winner?
      self.funded_description ||= about_project
    end

    true
  end

  def update_photo_order
    return unless @photo_order.present?

    ids = @photo_order.split(" ").map(&:to_i)

    # Update the sort order for each photo
    ids.each_with_index do |id, index|
      photos.where(id: id).update_all(sort_order: index)
    end
  end

  def delete_photos
    return unless @photo_ids_to_delete.present?

    @photo_ids_to_delete.each do |id|
      if photo = photos.find(id)
        photo.destroy
      end
    end
  end
end
