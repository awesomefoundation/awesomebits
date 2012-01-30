class RenameSubmissionsToProjects < ActiveRecord::Migration
  def change
    rename_table :projects, :accepted_projects
    rename_table :submissions, :projects
  end
end
