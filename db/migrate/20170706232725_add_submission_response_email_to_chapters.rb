class AddSubmissionResponseEmailToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :submission_response_email, :text
  end
end
