class Project < ActiveRecord::Base
  belongs_to :chapter
  has_many :votes
  has_many :users, :through => :votes
  has_many :photos, :order => "photos.sort_order asc, photos.id asc"

  attr_accessible :name, :title, :url, :email, :phone, :about_me, :about_project,
                  :chapter_id, :extra_question_1, :extra_question_2, :extra_question_3,
                  :extra_answer_1, :extra_answer_2, :extra_answer_3,
                  :new_photos, :photo_order, :rss_feed_url, :use_for_money, :funded_on

  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :email
  validates_presence_of :about_me
  validates_presence_of :about_project
  validates_presence_of :use_for_money
  validates_presence_of :chapter_id

  cattr_accessor :mailer
  self.mailer = ProjectMailer

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
    start_date ||= 100.years.ago.to_date
    end_date ||= Date.today
    where("projects.created_at BETWEEN ? AND ?", start_date, end_date + 1.day)
  end

  def self.voted_on_during_timeframe(start_date, end_date)
    start_date ||= 100.years.ago.to_date
    end_date ||= Date.today
    joins(:users).where("votes.created_at BETWEEN ? AND ?", start_date, end_date + 1.day)
  end

  def self.by_vote_count
    select("projects.id, projects.title, COUNT(votes.project_id) as vote_count").
      group("projects.id, projects.title, votes.project_id").
      joins(:users).
      order("vote_count DESC")
  end

  def self.recent_winners
    where('projects.funded_on is not null').order(:funded_on).reverse_order
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
    %w(name url email phone about_me chapter_id created_at about_project title funded_on extra_question_1 extra_question_2 extra_question_3 extra_answer_1 extra_answer_2 extra_answer_3 rss_feed_url use_for_money)
  end

  def to_a
    self.class.attributes_for_export.collect { |attr| send(attr).to_s }
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
      new_photo = self.photos.build(:image => photo)
      if persisted?
        new_photo.save
      end
    end
  end

  def display_images
    if photos.empty?
      [Photo.new.image]
    else
      photos.map(&:image)
    end
  end

  def primary_image
    display_images.first
  end

  def save
    was_new_record = new_record?
    saved = super
    if saved && was_new_record
      mailer.new_application(self).deliver
    end
    saved
  end
end
