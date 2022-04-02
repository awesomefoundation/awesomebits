class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :chapter

  validates_presence_of :user_id
  validates_presence_of :project_id
  validates_presence_of :chapter_id

  validates_uniqueness_of :user_id, :scope => :project_id

  validate :ensure_chapter, on: :create

  def self.by(user)
    where(:user_id => user.id)
  end

  def self.for(project)
    where(:project_id => project.id)
  end

  private

  def ensure_chapter
    unless user && user.chapters.include?(chapter)
      self.errors.add(:chapter_id, :invalid_for_user)
    end
  end
end
