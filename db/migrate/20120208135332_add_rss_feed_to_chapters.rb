class AddRssFeedToChapters < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :rss_feed_url, :string
  end
end
