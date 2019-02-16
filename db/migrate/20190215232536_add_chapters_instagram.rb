class AddChaptersInstagram < ActiveRecord::Migration
  def change
    add_column :chapters, :instagram_url, :string
  end
end
