class AddSortOrderToPhotos < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :sort_order, :integer, :default => 9999, :null => false
    add_index :photos, :sort_order
  end
end
