class ProjectRssFeedUrl < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :rss_feed_url, :string
  end
end
