require "rails_helper"

RSpec.describe ProjectAnalysisGenerator, type: :service do
  let(:project) { create(:project) }

  before do
    # Mock the OpenAI API client
    @mock_client = instance_double(OpenAI::Client)
    allow(OpenAI::Client).to receive(:new).and_return(@mock_client)
  end

  describe "#call" do
    context "when OpenAI API returns a valid response" do
      it "creates a ProjectAnalysis record" do
        # Mock the API response
        api_response = {
          "choices" => [
            {
              "message" => {
                "content" => {
                  "summary" => "A great project.",
                  "language_code" => "en",
                  "applicant_role" => "Founder",
                  "scores" => {
                    "impact" => {"score" => 0.9, "reason" => "High impact"},
                    "feasibility" => {"score" => 0.8, "reason" => "Feasible"},
                    "innovation" => {"score" => 0.7, "reason" => "Innovative"}
                  }
                }.to_json
              }
            }
          ]
        }
        allow(@mock_client).to receive(:chat).and_return(api_response)

        generator = ProjectAnalysisGenerator.new(project.id)
        expect {
          generator.call
        }.to change { ProjectAnalysis.count }.by(1)

        analysis = ProjectAnalysis.last
        expect(analysis.summary).to eq("A great project.")
        expect(analysis.language_code).to eq("en")
        expect(analysis.scores.impact_score).to eq(0.9)
        expect(analysis.scores.impact_reason).to eq("High impact")
      end
    end

    context "when OpenAI API fails" do
      it "raises an error" do
        allow(@mock_client).to receive(:chat).and_raise(StandardError.new("API Error"))

        generator = ProjectAnalysisGenerator.new(project.id)
        expect { generator.call }.to raise_error("Error: OpenAI API call failed.")
      end
    end
  end
end
