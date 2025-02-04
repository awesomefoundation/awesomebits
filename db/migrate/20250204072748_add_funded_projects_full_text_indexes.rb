class AddFundedProjectsFullTextIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :projects, %{to_tsvector('english', email)}, using: :gin
    add_index :projects, %{to_tsvector('english', url)}, using: :gin
    add_index :projects, %{to_tsvector('english', funded_description)}, using: :gin
  end
end
