class ChangeProjectInfoColumnNames < ActiveRecord::Migration
  def up
    rename_column :projects, :description, :about_me
    rename_column :projects, :use, :about_project
    add_column :projects, :use_for_money, :text
  end

  def down
    remove_column :projects, :use_for_money
    rename_column :projects, :about_project, :use
    rename_column :projects, :about_me, :description
  end
end
