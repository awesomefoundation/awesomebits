class RemoveExtraFieldsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :login_count
    remove_column :users, :failed_login_count
    remove_column :users, :last_request_at
    remove_column :users, :current_login_at
    remove_column :users, :last_login_at
    remove_column :users, :current_login_ip
    remove_column :users, :last_login_ip
  end

  def down
    add_column :users, :last_login_ip, :string
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_request_at, :datetime
    add_column :users, :failed_login_count, :integer
    add_column :users, :login_count, :integer
  end
end
