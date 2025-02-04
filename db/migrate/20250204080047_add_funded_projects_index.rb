class AddFundedProjectsIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :projects, :funded_on
  end
end
