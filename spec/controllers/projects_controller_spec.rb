require 'spec_helper'

describe ProjectsController do
  context "routing" do
    let(:boston){ FactoryGirl.build_stubbed(:chapter) }
    it "routes /chapters/boston/projects to projects#index" do
      {get: "/chapters/boston/projects"}.should
        route_to({controller: "projects", action: "index", id: boston.id, locale: "en"})
    end
    it "routes /en/chapters/boston/projects to projects#index" do
      {get: "/en/chapters/boston/projects"}.should
        route_to({controller: "projects", action: "index", id: boston.id, locale: "en"})
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
      delete :destroy, id: project
    end
    it { should redirect_to(chapter_projects_path(project.chapter)) }
  end

  context 'viewing the index without a chapter' do
    let(:chapter) { create(:chapter) }
    let(:user) { create(:user) }
    let!(:role) { create(:role, user: user, chapter: chapter) }

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
    let!(:role)     { create :role, user: user, chapter: chapter }

    before do
      sign_in_as user
      get :index, chapter_id: chapter, format: :csv
    end

    it { response.header['Content-Type'].should include 'csv' }
  end

  context 'viewing a public project page that has not won yet' do
    let!(:project) { create(:project) }
    let!(:user) { create(:user) }
    let!(:role) { create(:role, user: user) }

    context 'while logged in' do
      before do
        sign_in_as user
        get :show, id: project
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(chapter_project_path(project.chapter, project)) }
    end

    context 'while not logged in' do
      before do
        sign_out
        get :show, id: project
      end
      it { should respond_with(:missing) }
    end
  end

  context 'viewing a project that has won while logged out' do
    let!(:project) { create(:project, funded_on: Date.today) }

    context "with the correct slug" do 
      before do
        get :show, id: project
      end
      
      it { should respond_with(:success) }
      it { should render_template("public_show") }
    end

    context "with an incorrect slug" do
      before do 
        get :show, id: "#{project.id}-this-is-a-bad-slug"
      end

      it { should respond_with(:moved_permanently) }
      it { should redirect_to(project_path(project)) }
    end
  end

  context "viewing a private project page" do
    render_views

    let!(:project) { create(:project) }
    let!(:trustee) { create(:user) }
    let!(:admin)   { create(:admin) }
    
    context "while not logged in" do 
      before do 
        sign_out
        get :show, chapter_id: project.chapter,  id: project
      end

      it { should redirect_to root_path }
    end
    
    context "while logged in as a trustee" do 
      before do 
        sign_in_as trustee
        get :show, chapter_id: project.chapter,  id: project
      end

      it { should render_template("show") }
    end

    context "while logged in as a admin" do 
      before do 
        sign_in_as admin
        get :show, chapter_id: project.chapter,  id: project
      end

      it { should render_template("show") }
    end
  end
end
