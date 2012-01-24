class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email, :null => false
      t.references :chapter
      t.references :invitee
      t.references :inviter
      t.boolean :accepted, :default => false, :null => false

      t.timestamps
    end
  end
end
