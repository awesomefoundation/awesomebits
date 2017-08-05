class AddChapterProjectReviewDates < ActiveRecord::Migration
  def up
    add_column :chapters, :project_review_start, :date
    add_column :chapters, :project_review_end, :date
  end

  def down
    remove_column :chapters, :project_review_start
    remove_column :chapters, :project_review_end
  end
end
