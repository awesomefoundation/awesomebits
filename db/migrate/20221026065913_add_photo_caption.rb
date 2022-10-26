class AddPhotoCaption < ActiveRecord::Migration[5.2]
  def change
    add_column :photos, :caption, :text
  end
end
