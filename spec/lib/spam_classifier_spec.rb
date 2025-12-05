# coding: utf-8
require 'spec_helper'

describe SpamClassifier do
  let(:metadata) { {} }
  let(:project) { FactoryBot.create(:project, metadata: metadata) }
  let(:classifier) { SpamClassifier.new(project) }

  describe "#analyze!" do
    context "with missing JS metadata" do
      let(:metadata) { {} }

      before { classifier.analyze! }

      it "adds missing_js_metadata signal" do
        expect(classifier.signals).to include("missing_js_metadata")
      end

      it "includes weight in score" do
        expect(classifier.score).to be >= 0.2
      end
    end

    context "with short time on page" do
      let(:metadata) { { "time_on_page_ms" => 5000, "timezone" => "UTC" } }

      before { classifier.analyze! }

      it "adds short_time_on_page signal" do
        expect(classifier.signals).to include("short_time_on_page")
      end
    end

    context "with suspicious user agent" do
      let(:metadata) { { "user_agent" => "HeadlessChrome/91.0", "timezone" => "UTC" } }

      before { classifier.analyze! }

      it "adds suspicious_user_agent signal" do
        expect(classifier.signals).to include("suspicious_user_agent")
      end
    end

    context "with gibberish fields" do
      let(:metadata) { { "timezone" => "UTC" } }

      before do
        project.update!(name: "kjKSJsa", title: "asdfgh", about_me: "qwerty", about_project: "zxcvbn")
        classifier.analyze!
      end

      it "adds gibberish_fields signal" do
        expect(classifier.signals).to include("gibberish_fields")
      end
    end

    context "with high paste ratio" do
      let(:metadata) { { "keystroke_count" => 10, "paste_count" => 8, "timezone" => "UTC" } }

      before { classifier.analyze! }

      it "adds high_paste_ratio signal" do
        expect(classifier.signals).to include("high_paste_ratio")
      end
    end

    context "with duplicated fields" do
      let(:project) { FactoryBot.build(:project,
          about_me: "КРАКЕН САЙТ — ОФИЦИАЛЬНЫЙ САЙТ ДАРКНЕТ МАРКЕТПЛЕЙСА КРАКЕН",
          about_project: "КРАКЕН САЙТ — ОФИЦИАЛЬНЫЙ САЙТ ДАРКНЕТ МАРКЕТПЛЕЙСА КРАКЕН \r\n \r\nИщете Кракен сайт?",
          use_for_money: "КРАКЕН САЙТ — ОФИЦИАЛЬНЫЙ САЙТ ДАРКНЕТ МАРКЕТПЛЕЙСА КРАКЕН",
          metadata: metadata
        )
      }

      before { classifier.analyze! }

      it "adds identical_fields signal" do
        expect(classifier.signals).to include("identical_fields")
      end
    end
  end

  describe "#suspected_spam?" do
    context "when score exceeds threshold" do
      let(:metadata) { { "user_agent" => "bot", "timezone" => "UTC" } }

      it "returns true" do
        classifier.analyze!
        expect(classifier.suspected_spam?).to be true
      end
    end

    context "when score is below threshold" do
      let(:metadata) { { "time_on_page_ms" => 30000, "timezone" => "UTC", "referrer" => "https://google.com" } }

      it "returns false" do
        classifier.analyze!
        expect(classifier.suspected_spam?).to be false
      end
    end
  end

  describe "#analysis" do
    let(:metadata) { { "time_on_page_ms" => 5000, "timezone" => "UTC", "referrer" => "https://google.com" } }

    before { classifier.analyze! }

    it "returns score and triggered signals" do
      result = classifier.analysis
      expect(result[:score]).to be > 0
      expect(result[:triggered]).to include("short_time_on_page")
    end
  end
end
