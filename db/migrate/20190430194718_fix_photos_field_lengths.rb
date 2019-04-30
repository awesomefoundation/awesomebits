class FixPhotosFieldLengths < ActiveRecord::Migration[5.2]
  def up
    change_column :photos, :image_file_name, :text
    change_column :photos, :direct_upload_url, :text
  end

  def down
    change_column :photos, :image_file_name, :string
    change_column :photos, :direct_upload_url, :string
  end
end
