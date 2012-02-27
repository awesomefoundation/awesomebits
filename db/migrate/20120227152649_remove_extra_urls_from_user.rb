class RemoveExtraUrlsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :chapter_id
    remove_column :users, :twitter_username
    remove_column :users, :facebook_url
    remove_column :users, :linkedin_url
  end
end
