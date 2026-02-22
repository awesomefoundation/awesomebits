# frozen_string_literal: true

require_relative "../../../scripts/signal-score/pre_scorer"

RSpec.describe PreScorer do
  describe "#analyze!" do
    context "with a typical funded application" do
      let(:project) do
        {
          "about_me" => "I'm a community organizer in Pilsen, Chicago. I've been running after-school programs for 5 years at Benito Juarez High School.",
          "about_project" => "We want to build a community garden on the vacant lot at 18th and Ashland. We've already gotten permission from the alderman's office and have 30 volunteers signed up.",
          "use_for_money" => "Seeds and soil: $400. Raised beds (lumber): $350. Tools: $150. Water hookup: $100.",
        }
      end

      subject { described_class.new(project).tap(&:analyze!).features }

      it "counts words per field" do
        expect(subject["word_count_about_me"]).to be > 10
        expect(subject["word_count_about_project"]).to be > 10
        expect(subject["word_count_use_for_money"]).to be > 5
      end

      it "detects money mentions" do
        expect(subject["money_mention_count"]).to eq(4) # $400, $350, $150, $100
      end

      it "finds URLs" do
        expect(subject["url_count"]).to eq(0)
      end

      it "detects no empty fields" do
        expect(subject["empty_field_count"]).to eq(0)
      end

      it "calculates field length variance" do
        expect(subject["field_length_variance"]).to be > 0
      end

      it "has reasonable sentence stats" do
        expect(subject["sentence_count"]).to be > 3
        expect(subject["avg_sentence_length"]).to be > 5
      end
    end

    context "with a spam/low-effort application" do
      let(:project) do
        {
          "about_me" => "me",
          "about_project" => "need money",
          "use_for_money" => "stuff",
        }
      end

      subject { described_class.new(project).tap(&:analyze!).features }

      it "has very low word counts" do
        expect(subject["word_count_total"]).to be < 10
      end

      it "has zero money mentions" do
        expect(subject["money_mention_count"]).to eq(0)
      end

      it "has low sentence count" do
        expect(subject["sentence_count"]).to be <= 3
      end
    end

    context "with international currencies" do
      let(:project) do
        {
          "about_me" => "Artist from Melbourne.",
          "about_project" => "Budget: A$800 for paint, 200 euros for brushes, 500 pounds for venue hire, NZ$300 for shipping.",
          "use_for_money" => "Materials and transport costs.",
        }
      end

      subject { described_class.new(project).tap(&:analyze!).features }

      it "detects multiple currency formats" do
        expect(subject["money_mention_count"]).to be >= 4
      end
    end

    context "with empty fields" do
      let(:project) do
        {
          "about_me" => "I'm a student.",
          "about_project" => "",
          "use_for_money" => nil,
        }
      end

      subject { described_class.new(project).tap(&:analyze!).features }

      it "counts empty fields" do
        expect(subject["empty_field_count"]).to eq(2)
      end
    end

    context "with TF-IDF features" do
      let(:project) do
        {
          "about_me" => "community garden volunteer",
          "about_project" => "build raised beds for neighborhood",
          "use_for_money" => "soil and seeds",
        }
      end

      before do
        # Load a minimal IDF table
        PreScorer.instance_variable_set(:@idf_table, {
          "community" => 2.5,
          "garden" => 4.0,
          "volunteer" => 3.5,
          "build" => 2.0,
          "raised" => 5.0,
          "beds" => 5.5,
          "neighborhood" => 3.8,
          "soil" => 6.0,
          "seeds" => 5.5,
        })
      end

      after do
        PreScorer.instance_variable_set(:@idf_table, nil)
      end

      subject { described_class.new(project).tap(&:analyze!).features }

      it "computes TF-IDF mean" do
        expect(subject["tfidf_mean"]).to be > 0
      end

      it "computes TF-IDF max" do
        expect(subject["tfidf_max"]).to be >= subject["tfidf_mean"]
      end

      it "counts unique matching terms" do
        expect(subject["tfidf_unique_terms"]).to be > 0
      end
    end
  end

  describe "seeded data", :signal_score_data do
    # These tests run against real data from .scratch/data/
    # Enable with: SIGNAL_SCORE_DATA=1 rspec --tag signal_score_data

    let(:duckdb_path) { File.expand_path("../../../.scratch/data/awesomebits.duckdb", __dir__) }

    before(:all) do
      skip "DuckDB not found at .scratch/data/" unless File.exist?(
        File.expand_path("../../../.scratch/data/awesomebits.duckdb", __dir__)
      )
      require "json"
      # Load projects via duckdb CLI
      raw = `duckdb #{File.expand_path("../../../.scratch/data/awesomebits.duckdb", __dir__)} -json -c "SELECT * FROM sample_400 LIMIT 50"`
      @projects = JSON.parse(raw)
    end

    it "processes real funded projects without errors" do
      funded = @projects.select { |p| p["actual_label"] == "funded" }
      skip "No funded projects in seed data" if funded.empty?

      funded.each do |p|
        scorer = PreScorer.new(p)
        expect { scorer.analyze! }.not_to raise_error
        expect(scorer.features["word_count_total"]).to be >= 0
      end
    end

    it "processes real hidden projects without errors" do
      hidden = @projects.select { |p| p["actual_label"] == "hidden" }
      skip "No hidden projects in seed data" if hidden.empty?

      hidden.each do |p|
        scorer = PreScorer.new(p)
        expect { scorer.analyze! }.not_to raise_error
      end
    end

    it "funded projects tend to have higher word counts than hidden" do
      funded = @projects.select { |p| p["actual_label"] == "funded" }
      hidden = @projects.select { |p| p["actual_label"] == "hidden" }
      skip "Not enough labeled data" if funded.length < 5 || hidden.length < 5

      funded_avg = funded.sum { |p| PreScorer.new(p).tap(&:analyze!).features["word_count_total"] } / funded.length.to_f
      hidden_avg = hidden.sum { |p| PreScorer.new(p).tap(&:analyze!).features["word_count_total"] } / hidden.length.to_f

      expect(funded_avg).to be > hidden_avg
    end
  end
end
