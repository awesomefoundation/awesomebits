# frozen_string_literal: true

require "sucker_punch"

# Scores a grant application asynchronously via the Signal Score pipeline.
#
# Enqueued after a new project is created. Uses the Anthropic Messages API
# to generate structured scores with the Trust Equation rubric.
#
# Usage:
#   ScoreGrantJob.perform_async(project_id)
#   ScoreGrantJob.new.perform(project_id)  # synchronous, for testing
#
class ScoreGrantJob
  include SuckerPunch::Job

  def perform(project_id)
    ActiveRecord::Base.connection_pool.with_connection do
      project = Project.find_by(id: project_id)
      return unless project

      # Skip if already scored
      return if project.metadata&.dig("signal_score", "composite_score").present?

      # Skip if scoring is disabled for this chapter
      config = SignalScoreConfig.resolve(project.chapter) rescue {}
      return unless config["enabled"]

      scorer = SignalScorer.new(project)
      scorer.score!

      Rails.logger.info(
        "[SignalScore] Project ##{project_id} scored: " \
        "#{scorer.composite_score} (#{scorer.score_label})"
      )
    rescue SignalScorer::ScoringError => e
      Rails.logger.error("[SignalScore] Failed to score project ##{project_id}: #{e.message}")
    rescue => e
      Rails.logger.error("[SignalScore] Unexpected error scoring project ##{project_id}: #{e.message}")
    end
  end
end
