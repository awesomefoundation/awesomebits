class AddSlugsToChapters < ActiveRecord::Migration
  def up
    add_column :chapters, :slug, :string
    select_all("SELECT id, name FROM chapters").each do |chapter|
      id = chapter["id"]
      slug = chapter["name"].downcase.gsub(/[^a-z]+/, "-")
      execute("UPDATE chapters SET slug = '#{slug}' WHERE id = #{id}")
    end
    change_column :chapters, :slug, :string, :null => false
    add_index :chapters, :slug, unique: true
  end

  def down
    remove_column :chapters, :slug
  end
end
