# frozen_string_literal: true

class AddSignalScoreIndex < ActiveRecord::Migration[7.0]
  def up
    # Ensure metadata column exists (CI runs db:migrate from scratch;
    # the squashed 001 migration doesn't include columns added later).
    unless column_exists?(:projects, :metadata)
      add_column :projects, :metadata, :jsonb, default: {}
      add_index :projects, :metadata, using: :gin
    end

    # Expression index on composite_score for efficient filtering and sorting.
    # Without this, every WHERE/ORDER on the JSONB field does a full table scan.
    execute <<~SQL
      CREATE INDEX IF NOT EXISTS idx_projects_signal_score_composite
        ON projects (((metadata->'signal_score'->>'composite_score')::float))
        WHERE metadata->'signal_score' IS NOT NULL;
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS idx_projects_signal_score_composite;"
  end
end
