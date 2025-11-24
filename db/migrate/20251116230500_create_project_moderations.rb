class CreateProjectModerations < ActiveRecord::Migration[7.2]
  def change
    create_table :project_moderations do |t|
      t.references :project, null: false, foreign_key: true
      t.string :status, null: false, default: "unreviewed"
      t.string :moderation_type, null: false, default: "spam"
      t.jsonb :signals, null: false, default: {}
      t.references :reviewed_by, null: true, foreign_key: { to_table: :users }
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :project_moderations, :status
    add_index :project_moderations, :moderation_type
    add_index :project_moderations, :signals, using: :gin
    # project_id index is automatically created by foreign key
  end
end
