class AddInvitationRoleName < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :role_name, :string, null: false, default: "trustee"
  end
end
