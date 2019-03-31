class AddCountryToChapters < ActiveRecord::Migration[4.2]
  def change
    add_column :chapters, :country, :string
  end
end
