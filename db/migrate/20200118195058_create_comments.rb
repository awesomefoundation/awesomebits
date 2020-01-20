class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :viewable_chapter_id
      t.text :body
      t.string :viewable_by, length: 20, null: false, index: true
      t.timestamps
    end
  end
end
