class AddHidingToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :hidden_reason, :string
    add_column :projects, :hidden_by_user_id, :integer
    add_column :projects, :hidden_at, :timestamp
  end
end
