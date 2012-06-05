class AddIndexToInvitation < ActiveRecord::Migration
  def change
    add_index :invitations, :invitee_id
    add_index :invitations, :inviter_id
  end
end
