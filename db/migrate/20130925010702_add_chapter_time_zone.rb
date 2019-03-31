class AddChapterTimeZone < ActiveRecord::Migration[4.2]
  def change
    add_column 'chapters', 'time_zone', :string, :limit => 50
  end
end
