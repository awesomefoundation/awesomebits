# frozen_string_literal: true

# Per-chapter configuration for the Signal Score pipeline.
#
# A row with chapter_id = NULL is the global default.
# Chapter-specific rows override any fields they set (deep merge).
#
# JSONB columns:
#   scoring_config:  model, temperature, few_shot_count, score_threshold, grant_amount, currency
#   prompt_overrides: system_prompt, rubric_addendum, few_shot_project_ids
#   category_config:  weights, disabled, custom
#
class SignalScoreConfig < ApplicationRecord
  belongs_to :chapter, optional: true

  validates :chapter_id, uniqueness: { allow_nil: true }
  validate :only_one_global_default

  scope :global_default, -> { where(chapter_id: nil) }
  scope :enabled, -> { where(enabled: true) }

  # Resolve config for a chapter: deep-merge chapter overrides onto global default.
  def self.resolve(chapter = nil)
    global = global_default.first
    return {} unless global

    base = {
      "scoring_config" => global.scoring_config,
      "prompt_overrides" => global.prompt_overrides,
      "category_config" => global.category_config,
      "enabled" => global.enabled,
    }

    if chapter
      override = find_by(chapter: chapter)
      if override
        base = deep_merge(base, {
          "scoring_config" => override.scoring_config,
          "prompt_overrides" => override.prompt_overrides,
          "category_config" => override.category_config,
          "enabled" => override.enabled,
        })
      end
    end

    base
  end

  private

  def only_one_global_default
    if chapter_id.nil? && self.class.global_default.where.not(id: id).exists?
      errors.add(:chapter_id, "global default already exists")
    end
  end

  def self.deep_merge(base, overlay)
    base.merge(overlay) do |_key, old_val, new_val|
      if old_val.is_a?(Hash) && new_val.is_a?(Hash)
        deep_merge(old_val, new_val)
      elsif new_val.nil? || (new_val.is_a?(Hash) && new_val.empty?)
        old_val
      else
        new_val
      end
    end
  end
end
