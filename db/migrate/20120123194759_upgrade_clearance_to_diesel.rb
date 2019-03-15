class UpgradeClearanceToDiesel < ActiveRecord::Migration[4.2]
  def self.up
    change_table(:users) do |t|
      t.rename :crypted_password, :encrypted_password
      t.change :encrypted_password, :string, :limit => 128, :null => true
      t.rename :password_salt, :salt
      t.change :salt, :string, :limit => 128, :null => true
      t.string :confirmation_token, :limit => 128
      t.string :remember_token, :limit => 128
      t.remove :persistence_token
      t.remove :perishable_token
      t.remove :login
    end

    add_index :users, :email
    add_index :users, :remember_token
  end

  def self.down
    change_table(:users) do |t|
      t.change :salt, :string, :limit => nil, :null => false
      t.rename :salt, :password_salt
      t.change :encrypted_password, :string, :limit => nil, :null => false
      t.rename :encrypted_password, :crypted_password
      t.remove :confirmation_token,:remember_token
      t.string :perishable_token, :null => false
      t.string :persistence_token, :null => false
      t.string :login, :null => false
    end
  end
end
