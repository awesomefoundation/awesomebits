class AddCountryToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :country, :string
  end
end
