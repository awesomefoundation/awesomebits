class AddEmailAddressToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :email_address, :string
  end
end
