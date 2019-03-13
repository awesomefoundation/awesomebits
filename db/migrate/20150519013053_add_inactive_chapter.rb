class AddInactiveChapter < ActiveRecord::Migration[4.2]
  def change
    add_column 'chapters', 'inactive_at', :timestamp, :default => nil
  end
end
