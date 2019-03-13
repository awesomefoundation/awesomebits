class AddSubmissionResponseEmailToChapters < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :submission_response_email, :text
  end
end
