class RenameSubmissionsToProjects < ActiveRecord::Migration[4.2]
  def change
    rename_table :projects, :accepted_projects
    rename_table :submissions, :projects
  end
end
