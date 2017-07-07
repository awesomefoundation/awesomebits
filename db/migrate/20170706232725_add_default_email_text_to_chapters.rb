class AddDefaultEmailTextToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :default_email_text, :text
  end
end
