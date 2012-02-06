require 'spec_helper'

describe Vote do
  context "validations" do
    before { FactoryGirl.create(:vote) }
    it { should belong_to :user }
    it { should belong_to :project }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :project_id }
    it { should validate_uniqueness_of(:user_id).scoped_to(:project_id) }
  end

  context ".by" do
    let!(:vote){ FactoryGirl.create(:vote) }
    let!(:other_vote) { FactoryGirl.create(:vote) }
    it 'returns the votes by a certain user' do
      Vote.by(vote.user).should == [vote]
    end
  end

  context ".for" do
    let!(:vote){ FactoryGirl.create(:vote) }
    let!(:other_vote) { FactoryGirl.create(:vote) }
    it 'returns the votes for a certain project' do
      Vote.for(vote.project).should == [vote]
    end
  end
end
