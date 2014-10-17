class AddPhotoDirectUploadUrl < ActiveRecord::Migration
  def change
    add_column 'photos', 'direct_upload_url', :string
  end
end
