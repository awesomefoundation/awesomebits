class AddIndexToInvitation < ActiveRecord::Migration[4.2]
  def change
    add_index :invitations, :invitee_id
    add_index :invitations, :inviter_id
  end
end
