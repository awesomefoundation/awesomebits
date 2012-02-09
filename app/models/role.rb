class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter

  validates_uniqueness_of :user_id, :scope => :chapter_id

  def self.can_invite?
    where(:name => "dean").any?
  end

  def self.can_invite_to_chapter?(chapter)
    where(:name => "dean", :chapter_id => chapter).any?
  end

  def self.can_mark_winner?(project)
    where(:name => "dean", :chapter_id => project.chapter).any?
  end

  def self.can_manage_chapter?(chapter)
    where(:name => "dean", :chapter_id => chapter).any?
  end

  def self.can_view_finalists_for?(chapter)
    where(:chapter_id => chapter).any?
  end

  def trustee?
    true
  end

  def dean?
    name == "dean"
  end
end
