class AddVotesChapter < ActiveRecord::Migration[5.2]
  def change
    add_reference :votes, :chapter
  end
end
