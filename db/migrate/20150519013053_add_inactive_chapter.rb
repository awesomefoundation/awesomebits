class AddInactiveChapter < ActiveRecord::Migration
  def change
    add_column 'chapters', 'inactive_at', :timestamp, :default => nil
  end
end
