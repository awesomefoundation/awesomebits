class EnsureUniquenessOfRolesAndInvitations < ActiveRecord::Migration[4.2]
  def up
    add_index :invitations, [:email, :chapter_id], :unique => true
    remove_index :roles, :column => [:user_id, :chapter_id]
    add_index :roles, [:user_id, :chapter_id], :unique => true
  end

  def down
    remove_index :roles, :column => [:user_id, :chapter_id]
    add_index :roles, [:user_id, :chapter_id]
    remove_index :invitations, :column => [:email, :chapter_id]
  end
end
