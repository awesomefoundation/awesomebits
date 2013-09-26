class AddChapterTimeZone < ActiveRecord::Migration
  def change
    add_column 'chapters', 'time_zone', :string, :limit => 50
  end
end
