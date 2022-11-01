require 'spec_helper'

describe ProjectsController do
  context "routing" do
    it "routes /chapters/boston/projects to projects#index" do
      expect({get: "/chapters/boston/projects"}).to route_to(
        {:controller => "projects", :action => "index", :chapter_id => "boston"}
      )
    end

    it "routes /en/chapters/boston/projects to projects#index" do
      expect({:get => "/en/chapters/boston/projects"}).to route_to(
        {:controller => "projects", :action => "index", :chapter_id => "boston", :locale => "en"}
      )
    end
  end

  context 'viewing the index when logged out' do
    before do
      get :index
    end

    it { is_expected.to redirect_to(root_path) }
  end

  context 'viewing the index with a search term' do
    render_views

    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project, title: "Find Me") }
    let!(:missing_project) { FactoryGirl.create(:project, chapter: project.chapter) }

    before do
      sign_in_as user
    end

    it "returns the matching project only" do
      get :index, params: { chapter_id: project.chapter, q: "Find Me" }

      expect(response.status).to eq(200)
      expect(response.body).to match("Find Me")
      expect(response.body).to match("1 Project")
    end
  end

  context 'attempting to delete a project as a trustee who is not the dean or an admin' do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project) }
    before do
      sign_in_as user
      delete :destroy, params: { id: project }
    end
    it { is_expected.to redirect_to(chapter_projects_path(project.chapter)) }
  end

  context 'viewing the index without a chapter' do
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:role) { FactoryGirl.create(:role, :user => user, :chapter => chapter) }

    before do
      sign_in_as user
      get :index
    end

    it { is_expected.to redirect_to(chapter_projects_path(chapter)) }
  end

  context 'downloading the csv report' do
    let!(:project)  { FactoryGirl.create :project }
    let!(:user)     { FactoryGirl.create :user }
    let!(:chapter)  { FactoryGirl.create :chapter }
    let!(:role)     { FactoryGirl.create :role, :user => user, :chapter => chapter }

    before do
      sign_in_as user
      get :index, params: { chapter_id: chapter }, format: :csv
    end

    it { expect(response.header['Content-Type']).to include 'csv' }
  end

  context "viewing a private project page" do
    render_views

    let!(:project) { FactoryGirl.create(:project) }
    let!(:trustee) { FactoryGirl.create(:user) }
    let!(:admin)   { FactoryGirl.create(:admin) }

    context "while not logged in" do
      before do
        sign_out
        get :show, params: { chapter_id: project.chapter, id: project }
      end

      it { is_expected.to redirect_to root_path }
    end

    context "while logged in as a trustee" do
      before do
        sign_in_as trustee
        get :show, params: { chapter_id: project.chapter, id: project }
      end

      it { is_expected.to render_template("show") }
    end

    context "while logged in as a admin" do
      before do
        sign_in_as admin
        get :show, params: { chapter_id: project.chapter, id: project }
      end

      it { is_expected.to render_template("show") }
    end

  end

  context "creating a project submission" do
    context "when incomplete but with an image" do
      render_views

      before do
        post :create, params: { project: { new_photo_direct_upload_urls: ["http://example.com/test.png"] } }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template("new") }
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
        put :hide, params: { id: Time.now.to_i, hidden_reason: reason }
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    context "with a legit project" do
      context "with a reason" do
        before :each do
          put :hide, params: { id: project.id, hidden_reason: reason, return_to: chapter_projects_path(project.chapter) }
        end

        it "hides the project" do
          project.reload
          expect(project.hidden_reason).to eq(reason)
          expect(project.hidden_by_user_id).to eq(user.id)
        end

        it "redirects to the appropriate place in the projects page" do
          expect(response).to redirect_to(chapter_projects_path(project.chapter, anchor: "project#{project.id}"))
        end
      end

      context "with a reason" do
        let(:return_to) { chapter_projects_path(project.chapter, q: project.title) }

        it "doesn't hide the project" do
          put :hide, params: { id: project.id, hidden_reason: "", return_to: return_to }
          project.reload
          expect(project).not_to be_hidden
        end

        it "sets a flash" do
          put :hide, params: { id: project.id, hidden_reason: "", return_to: return_to }
          expect(flash[:notice]).not_to be_blank
        end

        it "redirects to the appropriate place in the projects page" do
          put :hide, params: { id: project.id, hidden_reason: "", return_to: return_to }
          expect(response).to redirect_to(chapter_projects_path(project.chapter, q: project.title, anchor: "project#{project.id}"))
        end

        it "defaults to page 1 by default" do
          put :hide, params: { id: project.id, hidden_reason: "" }
          expect(response).to redirect_to(chapter_projects_path(project.chapter, anchor: "project#{project.id}"))
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
        put :unhide, params: { id: Time.now.to_i }
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    context "with a legit project" do
      before :each do
        put :unhide, params: { id: project.id, unhidden_reason: reason }
      end

      it "unhides the project" do
        project.reload
        expect(project).not_to be_hidden
      end

      it "redirects to the project project" do
        expect(response).to redirect_to(chapter_project_path(project.chapter, project))
      end
    end
  end
end
