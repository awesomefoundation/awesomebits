class ProjectAnalysisJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    ProjectAnalysisGenerator.new(project_id).call
  rescue => e
    Rails.logger.error("Failed to generate project analysis for Project #{project_id}: #{e.message}")
  end
end
