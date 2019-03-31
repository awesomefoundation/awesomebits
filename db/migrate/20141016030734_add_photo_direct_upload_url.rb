class AddPhotoDirectUploadUrl < ActiveRecord::Migration[4.2]
  def change
    add_column 'photos', 'direct_upload_url', :string
  end
end
