class AddApplicationIntro < ActiveRecord::Migration[5.2]
  def change
    add_column :chapters, :application_intro, :text
  end
end
