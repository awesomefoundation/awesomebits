class AddEmailAddressToChapter < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :email_address, :string
  end
end
