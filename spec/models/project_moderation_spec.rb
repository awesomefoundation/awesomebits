require 'spec_helper'

describe ProjectModeration do
  let(:project) { FactoryBot.create(:project) }
  let(:user) { FactoryBot.create(:user) }

  describe "validations" do
    it "validates uniqueness of project_id" do
      FactoryBot.create(:project_moderation, project: project)

      duplicate_moderation = FactoryBot.build(:project_moderation, project: project)
      expect(duplicate_moderation).not_to be_valid
      expect(duplicate_moderation.errors[:project_id]).to include("has already been taken")
    end
  end
  let(:project_moderation) { FactoryBot.create(:project_moderation, project: project) }

  describe "#mark_confirmed_spam!" do
    it "updates status to confirmed_spam" do
      project_moderation.mark_confirmed_spam!(user)
      expect(project_moderation.status).to eq("confirmed_spam")
    end

    it "sets reviewed_by to the user" do
      project_moderation.mark_confirmed_spam!(user)
      expect(project_moderation.reviewed_by).to eq(user)
    end

    it "sets reviewed_at to current time" do
      before_time = Time.current
      project_moderation.mark_confirmed_spam!(user)
      expect(project_moderation.reviewed_at).to be >= before_time
    end
  end

  describe "#mark_confirmed_legit!" do
    it "updates status to confirmed_legit" do
      project_moderation.mark_confirmed_legit!(user)
      expect(project_moderation.status).to eq("confirmed_legit")
    end

    it "sets reviewed_by to the user" do
      project_moderation.mark_confirmed_legit!(user)
      expect(project_moderation.reviewed_by).to eq(user)
    end

    it "sets reviewed_at to current time" do
      before_time = Time.current
      project_moderation.mark_confirmed_legit!(user)
      expect(project_moderation.reviewed_at).to be >= before_time
    end
  end

  describe "#reviewed?" do
    it "returns true when reviewed_by is present" do
      project_moderation.update!(reviewed_by: user)
      expect(project_moderation.reviewed?).to be true
    end

    it "returns false when reviewed_by is nil" do
      project_moderation.update!(reviewed_by: nil)
      expect(project_moderation.reviewed?).to be false
    end
  end

  describe "scopes" do
    let!(:unreviewed) { FactoryBot.create(:project_moderation, status: "unreviewed") }
    let!(:suspected) { FactoryBot.create(:project_moderation, status: "suspected") }
    let!(:confirmed_spam) { FactoryBot.create(:project_moderation, status: "confirmed_spam") }
    let!(:confirmed_legit) { FactoryBot.create(:project_moderation, status: "confirmed_legit") }

    describe ".pending" do
      it "includes unreviewed and suspected moderations" do
        expect(ProjectModeration.pending).to contain_exactly(unreviewed, suspected)
      end
    end

    describe ".approved" do
      it "includes only confirmed_legit moderations" do
        expect(ProjectModeration.approved).to contain_exactly(confirmed_legit)
      end
    end
  end
end
