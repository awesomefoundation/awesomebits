require 'spec_helper'

describe SpamChecker do
  context "Project" do
    let(:checker) { SpamChecker::Project }
    it "updates the blocklist from the SPAM_REGEXP environment variable" do
      ENV['SPAM_REGEXP'] = "bob|felix"

      expect(checker.new(Project.new(about_me: "bob is a spammer")).spam?).to be true
      expect(checker.new(Project.new(about_me: "felix is a spammer")).spam?).to be true
      expect(checker.new(Project.new(about_me: "sandy is not a spammer")).spam?).to be false
    end

    it "functions without the SPAM_REGEXP environment variable" do
      expect(checker.new(Project.new).spam?).to be false
    end
  end
end
