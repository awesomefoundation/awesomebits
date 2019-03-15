class AddIndexToPhoto < ActiveRecord::Migration[4.2]
  def change
    add_index :photos, :project_id
  end
end
