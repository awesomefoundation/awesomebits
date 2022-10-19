class AddShrine < ActiveRecord::Migration[5.2]
  def change
    add_column :photos, :image_data, :jsonb
  end
end
