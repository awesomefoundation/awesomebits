# frozen_string_literal: true

class CreateSignalScoreConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :signal_score_configs do |t|
      t.references :chapter, null: true, foreign_key: true, index: { unique: true }
      t.jsonb :scoring_config, null: false, default: {}
      t.jsonb :prompt_overrides, null: false, default: {}
      t.jsonb :category_config, null: false, default: {}
      t.boolean :enabled, default: false, null: false
      t.timestamps
    end

    # Partial index for quick lookup of the global default (chapter_id IS NULL)
    add_index :signal_score_configs, :enabled,
              where: "chapter_id IS NULL",
              name: "index_signal_score_configs_on_global_default"
  end
end
