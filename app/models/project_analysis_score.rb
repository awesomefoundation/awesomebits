# app/models/project_analysis_score.rb
class ProjectAnalysisScore
  attr_accessor :score, :reason

  def initialize(score:, reason:)
    @score = score
    @reason = reason
  end
end
