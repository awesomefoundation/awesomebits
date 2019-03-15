class LastChapterUserIsViewing < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_viewed_chapter_id, :int
  end
end
