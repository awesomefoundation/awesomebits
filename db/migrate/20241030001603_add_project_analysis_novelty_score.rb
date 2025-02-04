class AddProjectAnalysisNoveltyScore < ActiveRecord::Migration[6.1]
  def change
    add_column :project_analyses, :novelty_score, :decimal, precision: 4, scale: 2
    add_column :project_analyses, :novelty_score_reason, :text
  end
end
