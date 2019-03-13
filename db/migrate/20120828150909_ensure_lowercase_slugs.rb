class EnsureLowercaseSlugs < ActiveRecord::Migration[4.2]
  def up
    execute("UPDATE chapters SET slug=LOWER(slug)")
  end

  def down
  end
end
