class Project < ActiveRecord::Base
  belongs_to :chapter
  has_many :votes
  has_many :users, :through => :votes

  attr_accessible :name, :title, :url, :email, :phone, :description, :use, :chapter_id

  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :email
  validates_presence_of :description
  validates_presence_of :use
  validates_presence_of :chapter_id

  cattr_accessor :mailer
  self.mailer = ProjectMailer

  def self.visible_to(user)
    joins(:chapter).
      joins("LEFT OUTER JOIN roles ON roles.chapter_id = chapters.id").
      where("roles.user_id = #{user.id} OR chapters.name = 'Any'")
  end

  def self.during_timeframe(start_date, end_date)
    start_date ||= 100.years.ago.to_date
    end_date ||= Date.today
    where("created_at BETWEEN ? AND ?", start_date, end_date + 1.day)
  end

  def shortlisted_by?(user)
    users.include?(user)
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
