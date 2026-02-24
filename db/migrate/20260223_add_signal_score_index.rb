# frozen_string_literal: true

class AddSignalScoreIndex < ActiveRecord::Migration[7.0]
  def up
    # Expression index on composite_score for efficient filtering and sorting.
    # Without this, every WHERE/ORDER on the JSONB field does a full table scan.
    execute <<~SQL
      CREATE INDEX idx_projects_signal_score_composite
        ON projects (((metadata->'signal_score'->>'composite_score')::float))
        WHERE metadata->'signal_score' IS NOT NULL;
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS idx_projects_signal_score_composite;"
  end
end
