require "rails_helper"

RSpec.describe "ProjectAnalysisGenerator Integration", type: :integration do
  let(:project) { create(:project) }

  before do
    skip "Integration test skipped: OPENAI_API_KEY is not configured." if ENV["OPENAI_API_KEY"].blank?
  end

  it "calls the OpenAI API with a real key and validates the response", integration: true do
    generator = ProjectAnalysisGenerator.new(project.id)
    expect { generator.call }.not_to raise_error

    analysis = ProjectAnalysis.last
    expect(analysis).not_to be_nil
    expect(analysis.summary).to be_a(String)
    expect(analysis.language_code).to be_a(String)
    expect(analysis.scores).to be_a(Hash)
    expect(analysis.scores).to include(*ProjectAnalysisScores::SCORE_FIELDS)

    [*ProjectAnalysisScores::SCORE_FIELDS].each do |field|
      expect(analysis.scores[field][:reason]).to be_a(String)
    end
  end
end
