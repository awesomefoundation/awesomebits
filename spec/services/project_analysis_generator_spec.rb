require "spec_helper"

RSpec.describe ProjectAnalysisGenerator, type: :service do
  let(:project) { create(:project) }
  let(:openai_config) do
    {
      api_key: "test-api-key",
      project_analysis: {
        model: "gpt-test",
        prompt_text: "Prompt",
        format_instructions: "Format",
        response_schema: {}
      }
    }
  end

  let(:mock_client) { mock("OpenAI::Client") }

  before do
    # Mock the OpenAI API client (Mocha)
    OpenAI::Client.stubs(:new).returns(mock_client)
    Rails.application.stubs(:config_for).with(:openai).returns(openai_config)
  end

  describe "#call" do
    context "when OpenAI API returns a valid response" do
      it "creates a ProjectAnalysis record" do
        scores = ProjectAnalysisScores::SCORE_FIELDS.each_with_object({}) do |field, hash|
          hash[field] = {"score" => 0.8, "reason" => "#{field} ok"}
        end
        # Mock the API response
        api_response = {
          "choices" => [
            {
              "message" => {
                "content" => {
                  "summary" => "A great project.",
                  "language_code" => "en",
                  "applicant_role" => "Founder",
                  "scores" => scores
                }.to_json
              }
            }
          ]
        }
        mock_client.stubs(:chat).returns(api_response)

        generator = ProjectAnalysisGenerator.new(project.id)
        expect {
          generator.call
        }.to change { ProjectAnalysis.count }.by(1)

        analysis = ProjectAnalysis.last
        expect(analysis.summary).to eq("A great project.")
        expect(analysis.language_code).to eq("en")
        expect(analysis.scores.feasibility.score).to eq(0.8)
        expect(analysis.scores.feasibility.reason).to eq("feasibility ok")
      end
    end

    context "when OpenAI API fails" do
      it "raises an error" do
        mock_client.stubs(:chat).raises(StandardError.new("API Error"))

        generator = ProjectAnalysisGenerator.new(project.id)
        expect { generator.call }.to raise_error("Error: OpenAI API call failed.")
      end
    end
  end
end
