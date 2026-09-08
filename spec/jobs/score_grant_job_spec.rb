# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe ScoreGrantJob do
  let(:chapter) { FactoryBot.create(:chapter) }
  let(:project) { FactoryBot.create(:project, chapter: chapter) }

  let(:score_response) do
    {
      "content" => [
        {
          "type" => "tool_use",
          "id" => "tool_123",
          "name" => "score_application",
          "input" => {
            "composite_score" => 0.65,
            "reason" => "Solid project.",
            "flags" => [],
            "features" => {
              "credibility" => 0.7, "reliability" => 0.6, "intimacy" => 0.7,
              "self_interest" => 0.3, "specificity" => 0.6, "creativity" => 0.5,
              "budget_alignment" => 0.7, "catalytic_potential" => 0.5,
              "community_benefit" => 0.6, "personal_voice" => 0.6,
              "ai_spam_likelihood" => 0.1, "ai_writing_likelihood" => 0.2,
            }
          }
        }
      ]
    }
  end

  before do
    SignalScoreConfig.create!(
      chapter_id: nil,
      scoring_config: { "model" => "claude-haiku-4-5-20251001" },
      prompt_overrides: {},
      category_config: {},
      enabled: true
    )
    @original_key = ENV["ANTHROPIC_API_KEY"]
    ENV["ANTHROPIC_API_KEY"] = "sk-ant-test"

    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(status: 200, body: score_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  after do
    if @original_key
      ENV["ANTHROPIC_API_KEY"] = @original_key
    else
      ENV.delete("ANTHROPIC_API_KEY")
    end
  end

  describe '#perform' do
    it 'scores the project' do
      described_class.new.perform(project.id)

      project.reload
      assert_equal 0.65, project.metadata["signal_score"]["composite_score"]
    end

    it 'skips if project already has a score' do
      project.update_column(:metadata, { "signal_score" => { "composite_score" => 0.5 } })

      described_class.new.perform(project.id)

      project.reload
      assert_equal 0.5, project.metadata["signal_score"]["composite_score"]
    end

    it 'skips if project does not exist' do
      expect { described_class.new.perform(999999) }.not_to raise_error
    end

    it 'skips and releases claim if scoring is disabled' do
      SignalScoreConfig.update_all(enabled: false)

      described_class.new.perform(project.id)

      project.reload
      assert_nil project.metadata&.dig("signal_score", "composite_score")
    end

    it 'prevents double-scoring via atomic claim' do
      project.update_column(:metadata, { "signal_score" => { "status" => "scoring" } })

      described_class.new.perform(project.id)

      project.reload
      assert_equal "scoring", project.metadata["signal_score"]["status"]
      assert_nil project.metadata["signal_score"]["composite_score"]
    end

    it 'cleans up claim on API failure after retries' do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 500, body: { "error" => { "type" => "server_error" } }.to_json)

      # Stub sleep to avoid slow tests
      ScoreGrantJob.any_instance.stubs(:sleep)

      described_class.new.perform(project.id)

      project.reload
      # Claim should be cleaned up after exhausting retries
      assert_nil project.metadata&.dig("signal_score")
    end
  end
end
