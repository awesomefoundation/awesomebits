require 'spec_helper'

describe ProjectsController do
  context 'viewing the index when logged out' do
    before do
      get :index
    end

    it { should redirect_to(root_path) }
  end

  context 'viewing the index without a chapter' do
    let(:chapter) { create(:chapter) }
    let(:user) { create(:user) }
    let!(:role) { create(:role, :user => user, :chapter => chapter) }

    before do
      sign_in_as user
      get :index
    end

    it { should redirect_to(chapter_projects_path(chapter)) }
  end

  context 'viewing a project that has not won yet' do
    let!(:project) { create(:project) }
    let!(:user) { create(:user) }
    let!(:role) { create(:role, :user => user) }
    context 'while logged in' do
      before do
        sign_in_as user
        get :show, :id => project
      end
      it { should respond_with(:success) }
    end
    context 'while not logged in' do
      before do
        sign_out
        get :show, :id => project
      end
      it { should redirect_to(root_path) }
    end
  end

  context 'viewing a project that has won while logged out' do
    let!(:project) { create(:project, :funded_on => Date.today) }
    before do
      get :show, :id => project
    end
    it { should respond_with(:success) }
  end
end
