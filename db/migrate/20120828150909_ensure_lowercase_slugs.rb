class EnsureLowercaseSlugs < ActiveRecord::Migration
  def up
    execute("UPDATE chapters SET slug=LOWER(slug)")
  end

  def down
  end
end
