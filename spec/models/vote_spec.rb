require 'spec_helper'

describe Vote do
  context "validations" do
    before { FactoryGirl.create(:vote) }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :project }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :project_id }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:project_id) }
  end

  context ".by" do
    let!(:vote){ FactoryGirl.create(:vote) }
    let!(:other_vote) { FactoryGirl.create(:vote) }
    it 'returns the votes by a certain user' do
      expect(Vote.by(vote.user)).to eq([vote])
    end
  end

  context ".for" do
    let!(:vote){ FactoryGirl.create(:vote) }
    let!(:other_vote) { FactoryGirl.create(:vote) }
    it 'returns the votes for a certain project' do
      expect(Vote.for(vote.project)).to eq([vote])
    end
  end
end
