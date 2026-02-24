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
      # Atomic claim: only proceed if no score exists yet.
      # This prevents double-scoring when multiple workers pick up the same job.
      claimed = Project.where(id: project_id)
        .where("metadata IS NULL OR metadata->'signal_score' IS NULL")
        .update_all("metadata = COALESCE(metadata, '{}'::jsonb) || '{\"signal_score\": {\"status\": \"scoring\"}}'::jsonb")
      return unless claimed > 0

      project = Project.find(project_id)

      # Skip if scoring is disabled for this chapter
      config = SignalScoreConfig.resolve(project.chapter) rescue {}
      unless config["enabled"]
        # Release the claim
        Project.where(id: project_id).update_all(
          "metadata = metadata - 'signal_score'"
        )
        return
      end

      scorer = SignalScorer.new(project)
      scorer.score!

      Rails.logger.info(
        "[SignalScore] Project ##{project_id} scored: " \
        "#{scorer.composite_score} (#{scorer.score_label})"
      )
    rescue SignalScorer::ScoringError => e
      Rails.logger.error("[SignalScore] Failed to score project ##{project_id}: #{e.message}")
      # Retry with exponential backoff (max 3 attempts)
      @retry_count = (@retry_count || 0) + 1
      if @retry_count < 3
        sleep_time = 2**@retry_count # 2s, 4s
        Rails.logger.info("[SignalScore] Retrying project ##{project_id} in #{sleep_time}s (attempt #{@retry_count + 1}/3)")
        sleep(sleep_time)
        retry
      else
        # Clear the "scoring" claim so the project can be retried later
        Project.where(id: project_id)
          .where("metadata->'signal_score'->>'status' = 'scoring'")
          .update_all("metadata = metadata - 'signal_score'")
        Rails.logger.error("[SignalScore] Gave up on project ##{project_id} after 3 attempts")
      end
    rescue => e
      Rails.logger.error("[SignalScore] Unexpected error scoring project ##{project_id}: #{e.class}: #{e.message}")
      # Clear claim on unexpected errors
      Project.where(id: project_id)
        .where("metadata->'signal_score'->>'status' = 'scoring'")
        .update_all("metadata = metadata - 'signal_score'")
    end
  end
end
