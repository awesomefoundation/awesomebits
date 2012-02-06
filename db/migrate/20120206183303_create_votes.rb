class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user
      t.references :project

      t.timestamps
    end

    add_index :votes, [:user_id, :project_id], :unique => true
  end
end
