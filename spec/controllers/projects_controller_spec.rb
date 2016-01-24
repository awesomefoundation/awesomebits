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
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project) }
    before do
      sign_in_as user
      delete :destroy, :id => project
    end
    it { should redirect_to(chapter_projects_path(project.chapter)) }
  end

  context 'viewing the index without a chapter' do
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:role) { FactoryGirl.create(:role, :user => user, :chapter => chapter) }

    before do
      sign_in_as user
      get :index
    end

    it { should redirect_to(chapter_projects_path(chapter)) }
  end

  context 'downloading the csv report' do
    let!(:project)  { FactoryGirl.create :project }
    let!(:user)     { FactoryGirl.create :user }
    let!(:chapter)  { FactoryGirl.create :chapter }
    let!(:role)     { FactoryGirl.create :role, :user => user, :chapter => chapter }

    before do
      sign_in_as user
      get :index, :chapter_id => chapter, :format => :csv
    end

    it { response.header['Content-Type'].should include 'csv' }
  end

  context 'viewing a public project page that has not won yet' do
    let!(:project) { FactoryGirl.create(:project) }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:role) { FactoryGirl.create(:role, :user => user) }

    context 'while logged in' do
      before do
        sign_in_as user
        get :show, :id => project
      end
      it { should respond_with(:redirect) }
      it { should redirect_to(chapter_project_path(project.chapter, project)) }
    end

    context 'while not logged in' do
      before do
        sign_out
        get :show, :id => project
      end
      it { should respond_with(:missing) }
    end
  end

  context 'viewing a project that has won while logged out' do
    let!(:project) { FactoryGirl.create(:project, :funded_on => Date.today) }

    context "with the correct slug" do
      before do
        get :show, :id => project
      end

      it { should respond_with(:success) }
      it { should render_template("public_show") }
    end

    context "with an incorrect slug" do
      before do
        get :show, :id => "#{project.id}-this-is-a-bad-slug"
      end

      it { should respond_with(:moved_permanently) }
      it { should redirect_to(project_path(project)) }
    end
  end

  context "viewing a private project page" do
    render_views

    let!(:project) { FactoryGirl.create(:project) }
    let!(:trustee) { FactoryGirl.create(:user) }
    let!(:admin)   { FactoryGirl.create(:admin) }

    context "while not logged in" do
      before do
        sign_out
        get :show, :chapter_id => project.chapter,  :id => project
      end

      it { should redirect_to root_path }
    end

    context "while logged in as a trustee" do
      before do
        sign_in_as trustee
        get :show, :chapter_id => project.chapter,  :id => project
      end

      it { should render_template("show") }
    end

    context "while logged in as a admin" do
      before do
        sign_in_as admin
        get :show, :chapter_id => project.chapter,  :id => project
      end

      it { should render_template("show") }
    end

  end

  describe "#hide" do
    let(:user) { FactoryGirl.create(:user) }
    let(:reason) { Faker::Company.bs }
    let(:project) { FactoryGirl.create(:project) }
    before do
      sign_in_as user
    end

    it "throws a RecordNotFound if the project doesn't exist" do
      expect {
        put :hide, id: Time.now.to_i, hidden_reason: reason
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    context "with a legit project" do
      context "with a reason" do
        before :each do
          put :hide, id: project.id, hidden_reason: reason
        end

        it "hides the project" do
          project.reload
          expect(project.hidden_reason).to eq(reason)
          expect(project.hidden_by_user_id).to eq(user.id)
        end

        it "redirects to the appropriate place in the projects page" do
          expect(response).to redirect_to(chapter_projects_path(project.chapter_id, anchor: "project#{project.id}"))
        end
      end

      context "with a reason" do
        let(:page) { 2 }

        it "doesn't hide the project" do
          put :hide, id: project.id, hidden_reason: "", page: page
          project.reload
          expect(project).not_to be_hidden
        end

        it "sets a flash" do
          put :hide, id: project.id, hidden_reason: "", page: page
          expect(flash[:notice]).not_to be_blank
        end

        it "redirects to the appropriate place in the projects page" do
          put :hide, id: project.id, hidden_reason: "", page: page
          expect(response).to redirect_to(chapter_projects_path(project.chapter_id, page: page, anchor: "project#{project.id}"))
        end

        it "defaults to page 1 by default" do
          put :hide, id: project.id, hidden_reason: ""
          expect(response).to redirect_to(chapter_projects_path(project.chapter_id, anchor: "project#{project.id}"))
        end
      end
    end
  end

  describe "#unhide" do
    let(:user) { FactoryGirl.create(:user) }
    let(:reason) { Faker::Company.bs }
    let(:project) { FactoryGirl.create(:project) }
    before do
      sign_in_as user
      project.hide!(reason, user)
    end

    it "throws a RecordNotFound if the project doesn't exist" do
      expect {
        put :unhide, id: Time.now.to_i
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    context "with a legit project" do
      before :each do
        put :unhide, id: project.id, unhidden_reason: reason
      end

      it "unhides the project" do
        project.reload
        expect(project).not_to be_hidden
      end

      it "redirects to the appropriate place in the projects page" do
        expect(response).to redirect_to(project_path(project.id))
      end
    end
  end
end
