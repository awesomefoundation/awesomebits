class AddMetadataToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :metadata, :jsonb, default: {}
    add_index :projects, :metadata, using: :gin
  end
end
