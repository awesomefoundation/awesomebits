class ProjectAnalysisScores
  SCORE_FIELDS = %w[
    self_interest
    proximity
    novelty
    budget_clarity
    whimsy
    social_good
    reach
    feasibility
    urgency
    impact_of_grant
    credibility
    innovation
    sustainability
    community_involvement
    cultural_relevance
    scalability
    alignment_with_mission
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
