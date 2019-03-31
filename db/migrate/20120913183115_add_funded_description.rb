class AddFundedDescription < ActiveRecord::Migration[4.2]
  def up
    add_column "projects", "funded_description", :text
    Project.reset_column_information
    execute("UPDATE projects SET funded_description=about_project WHERE funded_on IS NOT NULL")
  end

  def down
    remove_column "projects", "funded_description"
  end
end
