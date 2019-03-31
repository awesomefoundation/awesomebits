class ChangeChapters < ActiveRecord::Migration[4.2]
  def up
    remove_column :chapters, :slug
    rename_column :chapters, :body, :description
    remove_column :chapters, :tagline
    remove_column :chapters, :submission_form_url
    add_column :chapters, :twitter_url, :string
    add_column :chapters, :facebook_url, :string
    add_column :chapters, :blog_url, :string
  end

  def down
    remove_column :chapters, :blog_url
    remove_column :chapters, :facebook_url
    remove_column :chapters, :twitter_url
    add_column :chapters, :submission_form_url, :string
    add_column :chapters, :tagline, :string
    rename_column :chapters, :description, :body
    add_column :chapters, :slug, :string
  end
end
