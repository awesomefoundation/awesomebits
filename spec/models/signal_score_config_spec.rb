# frozen_string_literal: true

require "spec_helper"

describe SignalScoreConfig do
  it { is_expected.to belong_to(:chapter).optional }

  describe "validations" do
    it "allows one global default (chapter_id = nil)" do
      config = described_class.create!(scoring_config: { "model" => "haiku" })
      expect(config).to be_persisted
      expect(config.chapter_id).to be_nil
    end

    it "prevents duplicate global defaults" do
      described_class.create!(scoring_config: { "model" => "haiku" })
      duplicate = described_class.new(scoring_config: { "model" => "sonnet" })
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:chapter_id]).to include("global default already exists")
    end

    it "allows multiple chapter-specific configs" do
      c1 = FactoryBot.create(:chapter)
      c2 = FactoryBot.create(:chapter)
      config1 = described_class.create!(chapter: c1, scoring_config: {})
      config2 = described_class.create!(chapter: c2, scoring_config: {})
      expect(config1).to be_persisted
      expect(config2).to be_persisted
    end

    it "prevents duplicate chapter configs" do
      chapter = FactoryBot.create(:chapter)
      described_class.create!(chapter: chapter, scoring_config: {})
      duplicate = described_class.new(chapter: chapter, scoring_config: {})
      expect(duplicate).not_to be_valid
    end
  end

  describe ".resolve" do
    let!(:global) do
      described_class.create!(
        scoring_config: { "model" => "haiku", "grant_amount" => 1000 },
        prompt_overrides: { "rubric_addendum" => "Be strict." },
        category_config: { "disabled" => [] },
        enabled: true,
      )
    end

    it "returns global config when no chapter specified" do
      result = described_class.resolve
      expect(result["scoring_config"]["model"]).to eq("haiku")
      expect(result["scoring_config"]["grant_amount"]).to eq(1000)
    end

    it "deep-merges chapter overrides onto global" do
      chapter = FactoryBot.create(:chapter)
      described_class.create!(
        chapter: chapter,
        scoring_config: { "model" => "sonnet", "temperature" => 0.5 },
        prompt_overrides: {},
        category_config: {},
        enabled: true,
      )

      result = described_class.resolve(chapter)
      # Chapter override wins
      expect(result["scoring_config"]["model"]).to eq("sonnet")
      expect(result["scoring_config"]["temperature"]).to eq(0.5)
      # Global default preserved where chapter doesn't override
      expect(result["scoring_config"]["grant_amount"]).to eq(1000)
      # Global prompt preserved (chapter has empty overrides)
      expect(result["prompt_overrides"]["rubric_addendum"]).to eq("Be strict.")
    end

    it "returns empty hash when no global default exists" do
      global.destroy!
      expect(described_class.resolve).to eq({})
    end
  end
end
