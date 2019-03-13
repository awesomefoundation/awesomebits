class AddFirstAndLastNamesToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :first_name, :string
    add_column :invitations, :last_name, :string
  end
end
