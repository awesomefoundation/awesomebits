class ProjectAnalysisScores
  SCORE_FIELDS = %w[
    reach
    proximity
    self_interest
    budget_clarity
    impact_of_grant
    feasibility
    credibility
    innovation
    sustainability
    community_involvement
    cultural_relevance
    scalability
    urgency
    alignment_with_mission
    whimsy
    social_good
    artistic_merit
  ]

  def initialize(project_analysis)
    @project_analysis = project_analysis
  end

  SCORE_FIELDS.each do |field|
    define_method(field) do
      ProjectAnalysisScore.new(
        score: @project_analysis.send(:"#{field}_score"),
        reason: @project_analysis.send(:"#{field}_score_reason")
      )
    end
  end
end
