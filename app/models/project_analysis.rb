class ProjectAnalysis < ApplicationRecord
  belongs_to :project, optional: true

  validates :summary, :language_code, :applicant_role, :scores, presence: true

  validate :validate_scores

  # Serialize the tags array
  # serialize :tags, Array

  # Access scores as a nested object
  def scores
    @scores ||= ProjectAnalysisScores.new(self)
  end

  private def validate_scores
    scores_class = ProjectAnalysisScores::SCORE_FIELDS
    scores_class.each do |field|
      score_value = send(:"#{field}_score")
      reason = send(:"#{field}_score_reason")

      if score_value.nil? || reason.blank?
        errors.add(:base, "Both score and reason must be present for #{field}")
      elsif score_value < 0 || score_value > 1
        errors.add(:base, "Score for #{field} must be between 0.0 and 1.0")
      end
    end
  end
end
