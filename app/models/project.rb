class Project < ActiveRecord::Base
  belongs_to :chapter
  has_many :votes
  has_many :users, :through => :votes

  attr_accessible :name, :title, :url, :email, :phone, :description, :use, :chapter_id,
                  :extra_question_1, :extra_question_2, :extra_question_3,
                  :extra_answer_1, :extra_answer_2, :extra_answer_3

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

  def self.voted_for_by_members_of(chapter)
    joins(:users => :chapters).where("chapters.id = #{chapter.id}")
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

  def shortlisted_by?(user)
    users.include?(user)
  end

  def deliver_winning_email
    mailer.winner(self).deliver
  end

  def declare_winner!
    self.funded_on = Date.today
    save
  end

  def revoke_winner!
    self.funded_on = nil
    save
  end

  def winner?
    funded_on.present?
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
