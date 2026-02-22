# frozen_string_literal: true

# SignalScorer — AI-assisted grant application pre-screening.
#
# Two-layer pipeline:
#   1. PreScorer: deterministic text features (zero cost, local)
#   2. LLM Scorer: Anthropic API with Trust Equation rubric
#
# Usage:
#   scorer = SignalScorer.new(project)
#   scorer.pre_score!          # deterministic features only
#   scorer.score!              # full LLM scoring (requires API key)
#   scorer.categorize!         # taxonomy classification
#   scorer.composite_score     # 0.0-1.0
#   scorer.categories          # { "public-art" => 0.8, ... }
#   scorer.tags                # ["mentorship", "emerging-artists"]
#
# Config resolution:
#   SignalScoreConfig.resolve(project.chapter) -> merged JSONB config
#
class SignalScorer
  attr_reader :project, :pre_score_features, :score_result, :category_result

  def initialize(project)
    @project = project
    @config = SignalScoreConfig.resolve(project.chapter)
  end

  def pre_score!
    # Deterministic features — always available, zero cost
    scorer = build_pre_scorer
    scorer.analyze!
    @pre_score_features = scorer.features
  end

  def composite_score
    score_result&.dig("composite_score")
  end

  def reason
    score_result&.dig("reason")
  end

  def flags
    score_result&.dig("flags") || []
  end

  def features
    score_result&.dig("features") || {}
  end

  def primary_category
    category_result&.dig("primary_category")
  end

  def categories
    category_result&.dig("categories") || {}
  end

  def tags
    category_result&.dig("tags") || []
  end

  private

  def build_pre_scorer
    # Convert ActiveRecord to hash for PreScorer compatibility
    attrs = if project.respond_to?(:attributes)
      project.attributes
    else
      project
    end
    PreScorer.new(attrs)
  end
end
