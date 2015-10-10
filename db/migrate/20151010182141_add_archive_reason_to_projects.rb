class AddArchiveReasonToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :archived_reason, :string
    add_column :projects, :archived_by_user_id, :integer
    add_column :projects, :archived_at, :timestamp
  end
end
