class AddFundedOnToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :funded_on, :date
  end
end
