class AddChapterLocale < ActiveRecord::Migration
  def change
    add_column :chapters, :locale, :string, :null => false, :default => "en"
  end
end
