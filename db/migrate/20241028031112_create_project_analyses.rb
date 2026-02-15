class CreateProjectAnalyses < ActiveRecord::Migration[6.1]
  def change
    create_table :project_analyses do |t|
      t.references :project, foreign_key: true, null: false

      t.text :summary
      t.string :language_code
      t.string :applicant_role
      t.date :funding_deadline
      t.string :tags, array: true

      # Scores (flattened)
      score_fields = [
        "reach",
        "proximity",
        "self_interest",
        "budget_clarity",
        "impact_of_grant",
        "feasibility",
        "credibility",
        "innovation",
        "sustainability",
        "community_involvement",
        "cultural_relevance",
        "scalability",
        "urgency",
        "alignment_with_mission",
        "whimsy",
        "social_good",
        "artistic_merit"
      ]

      score_fields.each do |field|
        t.decimal "#{field}_score", precision: 4, scale: 2
        t.text "#{field}_score_reason"
      end

      t.timestamps
    end
  end
end
