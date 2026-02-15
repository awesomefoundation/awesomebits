class AddProjectAnalysisSuggestionColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :project_analyses, :suggestion, :text
  end
end
