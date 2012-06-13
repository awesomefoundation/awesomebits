require 'spec_helper'

describe ProjectsController do
  context "routing" do
    let(:boston){ FactoryGirl.build_stubbed(:chapter) }
    it "routes /chapters/boston/projects to projects#index" do
      {:get => "/chapters/boston/projects"}.should
        route_to({:controller => "projects", :action => "index", :id => boston.id, :locale => "en"})
    end
    it "routes /en/chapters/boston/projects to projects#index" do
      {:get => "/en/chapters/boston/projects"}.should
        route_to({:controller => "projects", :action => "index", :id => boston.id, :locale => "en"})
    end
  end
  context 'viewing the index when logged out' do
    before do
      get :index
    end

    it { should redirect_to(root_path) }
  end

  context 'attempting to delete a project as a trustee who is not the dean or an admin' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    before do
      sign_in_as user
      delete :destroy, :id => project
    end
    it { should redirect_to(chapter_projects_path(project.chapter)) }
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

  context 'downloading the csv report' do
    let!(:project)  { create :project }
    let!(:user)     { create :user }
    let!(:chapter)  { create :chapter }
    let!(:role)     { create :role, :user => user, :chapter => chapter }

    before do
      sign_in_as user
      get :index, :chapter_id => chapter, :format => :csv
    end

    it { should respond_with_content_type(:csv) }
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
