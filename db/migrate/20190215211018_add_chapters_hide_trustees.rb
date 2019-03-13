class AddChaptersHideTrustees < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :hide_trustees, :boolean, :null => false, :default => false
  end
end
