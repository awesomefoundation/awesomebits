class LastChapterUserIsViewing < ActiveRecord::Migration
  def change
    add_column :users, :last_viewed_chapter_id, :int
  end
end
