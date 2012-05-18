require 'spec_helper'

describe VotesController do
  let(:role) { create(:role) }
  let(:user) { role.user }
  let(:chapter) { role.chapter }
  let(:project) { create(:project, :chapter => chapter) }

  context "user can vote on a project" do
    before do
      sign_in_as user
      post :create, :project_id => project.id
    end
    it { should respond_with(:success) }
    it { should respond_with_content_type(:json) }
  end

  context "user can remove vote from project" do
    let!(:vote) { create(:vote, :project => project, :user => user) }
    before do
      sign_in_as user
      delete :destroy, :project_id => project.id
    end
    it { should respond_with(:success) }
    it { should respond_with_content_type(:json) }
  end

  context "error when user votes for a second time on a project" do
    let!(:vote) { create(:vote, :project => project, :user => user) }
    before do
      sign_in_as user
      post :create, :project_id => project.id
    end
    it { should respond_with(400) }
    it { should respond_with_content_type(:json) }
  end

  context "error when user trieds to delete a vote that doesn't exist" do
    before do
      sign_in_as user
      delete :destroy, :project_id => project.id
    end
    it { should respond_with(400) }
    it { should respond_with_content_type(:json) }
  end

end
