class AddFundedOnToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :funded_on, :date
  end
end
