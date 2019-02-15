class AddChaptersHideTrustees < ActiveRecord::Migration
  def change
    add_column :chapters, :hide_trustees, :boolean, :null => false, :default => false
  end
end
