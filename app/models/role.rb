class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter

  def self.deans_for_chapter(chapter)
    where(:name => "dean", :chapter_id => chapter.id)
  end

  def trustee?
    true
  end

  def dean?
    name == "dean"
  end
end
