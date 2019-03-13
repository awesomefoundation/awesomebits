class AddChaptersInstagram < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :instagram_url, :string
  end
end
