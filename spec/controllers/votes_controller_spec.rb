require 'spec_helper'

describe VotesController do
  let(:role) { FactoryGirl.create(:role) }
  let(:user) { role.user }
  let(:chapter) { role.chapter }
  let(:project) { FactoryGirl.create(:project, :chapter => chapter) }

  context "user can vote on a project" do
    before do
      sign_in_as user
      post :create, :project_id => project.id
    end
    it { is_expected.to respond_with(:success) }
    it { expect(response.header['Content-Type']).to include 'json' }
  end

  context "user can remove vote from project" do
    let!(:vote) { FactoryGirl.create(:vote, :project => project, :user => user) }
    before do
      sign_in_as user
      delete :destroy, :project_id => project.id
    end
    it { is_expected.to respond_with(:success) }
    it { expect(response.header['Content-Type']).to include 'json' }
  end

  context "error when user votes for a second time on a project" do
    let!(:vote) { FactoryGirl.create(:vote, :project => project, :user => user) }
    before do
      sign_in_as user
      post :create, :project_id => project.id
    end
    it { is_expected.to respond_with(400) }
    it { expect(response.header['Content-Type']).to include 'json' }
  end

  context "error when user trieds to delete a vote that doesn't exist" do
    before do
      sign_in_as user
      delete :destroy, :project_id => project.id
    end
    it { is_expected.to respond_with(400) }
    it { expect(response.header['Content-Type']).to include 'json' }
  end

end
