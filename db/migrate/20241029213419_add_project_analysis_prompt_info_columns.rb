class AddProjectAnalysisPromptInfoColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :project_analyses, :prompt_usage_data, :jsonb, default: {}, null: false
    add_column :project_analyses, :prompt_tokens, :integer
    add_column :project_analyses, :completion_tokens, :integer
    add_column :project_analyses, :cached_tokens, :integer
    add_column :project_analyses, :prompt_estimated_cost, :float
    add_column :project_analyses, :prompt_input_params, :jsonb, default: {}, null: false
    add_column :project_analyses, :prompt_response_data, :jsonb, default: {}, null: false
  end
end
