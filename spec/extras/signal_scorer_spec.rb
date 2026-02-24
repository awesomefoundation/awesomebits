require 'spec_helper'
require 'webmock/rspec'

describe SignalScorer do
  let(:chapter) { FactoryBot.create(:chapter) }
  let(:project) { FactoryBot.create(:project, chapter: chapter) }

  let(:api_key) { "sk-ant-test-key" }
  let(:scorer) { described_class.new(project, api_key: api_key) }

  let(:score_response) do
    {
      "content" => [
        {
          "type" => "tool_use",
          "id" => "tool_123",
          "name" => "score_application",
          "input" => {
            "composite_score" => 0.72,
            "reason" => "Strong community project with clear budget.",
            "flags" => [],
            "features" => {
              "credibility" => 0.8,
              "reliability" => 0.7,
              "intimacy" => 0.9,
              "self_interest" => 0.2,
              "specificity" => 0.8,
              "creativity" => 0.7,
              "budget_alignment" => 0.9,
              "catalytic_potential" => 0.6,
              "community_benefit" => 0.8,
              "personal_voice" => 0.7,
              "ai_spam_likelihood" => 0.1,
              "ai_writing_likelihood" => 0.2,
            }
          }
        }
      ]
    }
  end

  before do
    # Create a global config
    SignalScoreConfig.create!(
      chapter_id: nil,
      scoring_config: { "model" => "claude-haiku-4-5-20251001" },
      prompt_overrides: {},
      category_config: {},
      enabled: true
    )
  end

  describe '#score!' do
    before do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 200, body: score_response.to_json, headers: { "Content-Type" => "application/json" })
    end

    it 'calls the Anthropic API and persists the score' do
      result = scorer.score!

      expect(result["composite_score"]).to eq(0.72)
      expect(result["reason"]).to eq("Strong community project with clear budget.")

      project.reload
      expect(project.metadata["signal_score"]["composite_score"]).to eq(0.72)
      expect(project.metadata["signal_score"]["scored_at"]).to be_present
      expect(project.metadata["signal_score"]["model"]).to eq("claude-haiku-4-5-20251001")
      expect(project.metadata["signal_score"]["variant"]).to eq("live")
    end

    it 'does not clobber existing metadata' do
      project.update_column(:metadata, { "other_key" => "preserved" })

      scorer.score!
      project.reload

      expect(project.metadata["other_key"]).to eq("preserved")
      expect(project.metadata["signal_score"]["composite_score"]).to eq(0.72)
    end

    it 'raises ScoringError without an API key' do
      scorer = described_class.new(project, api_key: nil)
      expect { scorer.score! }.to raise_error(SignalScorer::ScoringError, /No Anthropic API key/)
    end

    it 'raises ScoringError on API failure without leaking response body' do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 429, body: { "error" => { "type" => "rate_limit_error", "message" => "secret stuff" } }.to_json)

      expect { scorer.score! }.to raise_error(SignalScorer::ScoringError, /429.*rate_limit_error/)
      expect { scorer.score! }.to raise_error { |e| expect(e.message).not_to include("secret stuff") }
    end

    it 'raises ScoringError when no tool_use block returned' do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 200, body: { "content" => [{ "type" => "text", "text" => "oops" }] }.to_json)

      expect { scorer.score! }.to raise_error(SignalScorer::ScoringError, /No tool_use block/)
    end
  end

  describe '#composite_score' do
    it 'returns nil before scoring' do
      expect(scorer.composite_score).to be_nil
    end
  end

  describe '#score_label' do
    before do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 200, body: score_response.to_json, headers: { "Content-Type" => "application/json" })
      scorer.score!
    end

    it 'returns the correct label' do
      expect(scorer.score_label).to eq("Strong")
    end
  end

  describe '#score_color' do
    before do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 200, body: score_response.to_json, headers: { "Content-Type" => "application/json" })
      scorer.score!
    end

    it 'returns green for strong scores' do
      expect(scorer.score_color).to eq("green")
    end
  end

  describe '#format_application' do
    it 'includes all present fields' do
      project = FactoryBot.create(:project,
        title: "Test Project",
        about_me: "About me text",
        about_project: "About project text",
        use_for_money: "$500 for supplies",
        url: "https://example.com"
      )
      scorer = described_class.new(project, api_key: api_key)
      text = scorer.send(:format_application)

      expect(text).to include("Title: Test Project")
      expect(text).to include("About Me: About me text")
      expect(text).to include("Use for Money: $500 for supplies")
      expect(text).to include("URL: https://example.com")
    end

    it 'skips blank fields' do
      project = FactoryBot.create(:project, title: "Test")
      # Set fields to blank after creation to bypass validations
      project.update_columns(about_me: nil, url: "")
      scorer = described_class.new(project.reload, api_key: api_key)
      text = scorer.send(:format_application)

      expect(text).to include("Title: Test")
      expect(text).not_to include("About Me:")
      expect(text).not_to include("URL:")
    end
  end
end
