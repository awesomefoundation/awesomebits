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

  MAX_RETRIES = 3

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
        release_claim!(project_id)
        return
      end

      score_with_retries!(project, project_id)
    rescue => e
      Rails.logger.error("[SignalScore] Unexpected error scoring project ##{project_id}: #{e.class}: #{e.message}")
      release_claim!(project_id)
    end
  end

  private

  def score_with_retries!(project, project_id)
    attempts = 0

    begin
      attempts += 1
      scorer = SignalScorer.new(project)
      scorer.score!

      Rails.logger.info(
        "[SignalScore] Project ##{project_id} scored: " \
        "#{scorer.composite_score} (#{scorer.score_label})"
      )
    rescue SignalScorer::ScoringError => e
      Rails.logger.error("[SignalScore] Failed to score project ##{project_id}: #{e.message}")

      if attempts < MAX_RETRIES
        sleep_time = 2**attempts # 2s, 4s
        Rails.logger.info("[SignalScore] Retrying project ##{project_id} in #{sleep_time}s (attempt #{attempts + 1}/#{MAX_RETRIES})")
        sleep(sleep_time)
        retry
      end

      Rails.logger.error("[SignalScore] Gave up on project ##{project_id} after #{MAX_RETRIES} attempts")
      release_claim!(project_id)
    end
  end

  def release_claim!(project_id)
    Project.where(id: project_id)
      .where("metadata->'signal_score'->>'status' = 'scoring'")
      .update_all("metadata = metadata - 'signal_score'")
  end
end
