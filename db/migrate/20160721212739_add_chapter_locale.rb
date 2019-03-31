class AddChapterLocale < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :locale, :string, :null => false, :default => "en"
  end
end
