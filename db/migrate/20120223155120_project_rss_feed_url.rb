class ProjectRssFeedUrl < ActiveRecord::Migration
  def change
    add_column :projects, :rss_feed_url, :string
  end
end
