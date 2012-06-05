class AddIndexToPhoto < ActiveRecord::Migration
  def change
    add_index :photos, :project_id
  end
end
