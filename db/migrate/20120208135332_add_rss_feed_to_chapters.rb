class AddRssFeedToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :rss_feed_url, :string
  end
end
