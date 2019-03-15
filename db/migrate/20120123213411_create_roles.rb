class CreateRoles < ActiveRecord::Migration[4.2]
  def up
    create_table :roles do |t|
      t.references :user, :null => false
      t.references :chapter, :null => false
      t.string :name, :null => false, :default => "trustee"
    end
    add_index :roles, [:user_id, :chapter_id]
  end

  def down
    remove_index :roles, :column => [:user_id, :chapter_id]
    drop_table :roles
  end
end
