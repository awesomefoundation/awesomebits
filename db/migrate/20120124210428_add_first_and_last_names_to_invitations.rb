class AddFirstAndLastNamesToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :first_name, :string
    add_column :invitations, :last_name, :string
  end
end
