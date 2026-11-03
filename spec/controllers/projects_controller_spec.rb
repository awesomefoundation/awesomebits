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

    it { is_expected.to redirect_to(sign_in_path) }
  end

  context 'viewing the index with a search term' do
    render_views

    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, title: "Find Me") }
    let!(:missing_project) { FactoryBot.create(:project, chapter: project.chapter) }

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
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project) }
    before do
      sign_in_as user
      delete :destroy, params: { id: project }
    end
    it { is_expected.to redirect_to(chapter_projects_path(project.chapter)) }
  end

  context 'viewing the index without a chapter' do
    let(:chapter) { FactoryBot.create(:chapter) }
    let(:user) { FactoryBot.create(:user) }
    let!(:role) { FactoryBot.create(:role, :user => user, :chapter => chapter) }

    before do
      sign_in_as user
      get :index
    end

    it { is_expected.to redirect_to(chapter_projects_path(chapter)) }
  end

  context 'downloading the csv report' do
    let!(:project)  { FactoryBot.create :project }
    let!(:user)     { FactoryBot.create :user }
    let!(:chapter)  { FactoryBot.create :chapter }
    let!(:role)     { FactoryBot.create :role, :user => user, :chapter => chapter }

    before do
      sign_in_as user
      get :index, params: { chapter_id: chapter }, format: :csv
    end

    it { expect(response.header['Content-Type']).to include 'csv' }
  end

  context "viewing a private project page" do
    render_views

    let!(:project) { FactoryBot.create(:project) }
    let!(:trustee) { FactoryBot.create(:user) }
    let!(:admin)   { FactoryBot.create(:admin) }

    context "while not logged in" do
      before do
        sign_out
        get :show, params: { chapter_id: project.chapter, id: project }
      end

      it { is_expected.to redirect_to sign_in_path }
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
    let(:fake_mailer) { FakeMailer.new }
    let(:chapter) { FactoryBot.create(:chapter) }
    let(:valid_project_params) do
      {
        name: "Test User",
        title: "Test Project",
        email: "test@example.com",
        about_me: "About me",
        about_project: "About project",
        use_for_money: "Use for money"
      }
    end

    before do
      Project.any_instance.stubs(:mailer).returns(fake_mailer)
    end

    context "that is valid" do
      it "creates a project and sends an email" do
        expect {
          post :create, params: { chapter: chapter.slug, project: valid_project_params }
        }.to change(Project, :count).by(1)

        expect(response).to redirect_to(success_submissions_path(chapter: chapter))
        expect(fake_mailer).to have_delivered_email(:new_application)
      end

      it "uses the top-level chapter slug instead of a nested chapter ID" do
        other_chapter = FactoryBot.create(:chapter)
        post :create, params: { chapter: chapter.slug, project: valid_project_params.merge(chapter_id: other_chapter.id) }

        expect(response).to be_redirect
        expect(Project.last.chapter).to eq(chapter)
      end
    end

    context "when the selected chapter has become inactive" do
      render_views

      it "rejects the submission and retains the draft" do
        chapter.update!(inactive_at: Time.current)

        expect {
          post :create, params: { chapter: chapter.slug, project: valid_project_params }
        }.not_to change(Project, :count)

        expect(response).to render_template(:new)
        expect(response.body).to include("Test User", "Test Project")
        expect(assigns(:project).errors[:chapter_id]).to be_present
        expect(fake_mailer).not_to have_delivered_email(:new_application)
      end
    end

    context "that is suspected of being spam" do
      it "creates a project but does not send an email" do
        Project.any_instance.stubs(:project_moderation).returns(ProjectModeration.new(status: :suspected))

        expect {
          post :create, params: { chapter: chapter.slug, project: valid_project_params }
        }.to change(Project, :count).by(1)

        expect(response).to redirect_to(success_submissions_path(chapter: chapter))
        expect(Project.last.not_pending_moderation?).to eq(false)
        expect(fake_mailer).to_not have_delivered_email(:new_application)
      end
    end

    context "with displayed questions" do
      render_views

      it "saves the displayed wording even if the chapter questions change" do
        chapter.update!(extra_question_1: "Replacement question?")
        post :create, params: { chapter: chapter.slug, project: valid_project_params.merge(extra_question_1: "Original question?", extra_answer_1: "Original answer") }

        expect(response).to be_redirect
        expect(Project.last.extra_question_1).to eq("Original question?")
        expect(Project.last.extra_answer_1).to eq("Original answer")
      end

      it "keeps optional answers optional" do
        post :create, params: { chapter: chapter.slug, project: valid_project_params.merge(extra_question_1: "Optional question?") }
        expect(response).to be_redirect
        expect(Project.last.extra_question_1).to eq("Optional question?")
        expect(Project.last.extra_answer_1).to be_blank
      end

      it "preserves submitted questions and answers when validation fails" do
        chapter.update!(extra_question_1: "Replacement question?")
        post :create, params: { chapter: chapter.slug, project: valid_project_params.merge(title: "", extra_question_1: "Original question?", extra_answer_1: "My answer") }
        expect(response.body).to include("Original question?", "My answer")
        expect(response.body).not_to include("Replacement question?")
        expect(Project.count).to eq(0)
      end
    end

    context "with client_metadata" do

      it "sanitizes malicious client_metadata fields" do
        malicious_metadata = {
          time_on_page_ms: "not_a_number",
          timezone: "x" * 1000, # Very long string
          screen_resolution: "1920x1080" * 100, # Very long string
          form_interactions_count: "5",
          keystroke_count: 42,
          paste_count: "invalid"
        }.to_json

        post :create, params: {
          chapter: chapter.slug,
          project: valid_project_params,
          client_metadata: malicious_metadata
        }

        expect(response).to redirect_to(success_submissions_path(chapter: chapter))

        project = Project.last
        expect(project.metadata["time_on_page_ms"]).to be_nil # Invalid integer
        expect(project.metadata["timezone"].length).to eq(50) # Truncated
        expect(project.metadata["screen_resolution"].length).to eq(20) # Truncated
        expect(project.metadata["form_interactions_count"]).to eq(5) # Valid integer from string
        expect(project.metadata["keystroke_count"]).to eq(42) # Valid integer
        expect(project.metadata["paste_count"]).to be_nil # Invalid integer
      end

      it "processes valid client_metadata correctly" do
        valid_metadata = {
          time_on_page_ms: 5000,
          timezone: "America/New_York",
          screen_resolution: "1920x1080",
          form_interactions_count: 3,
          keystroke_count: 42,
          paste_count: 1
        }.to_json

        post :create, params: {
          chapter: chapter.slug,
          project: valid_project_params,
          client_metadata: valid_metadata
        }

        expect(response).to redirect_to(success_submissions_path(chapter: chapter))

        project = Project.last
        expect(project.metadata["time_on_page_ms"]).to eq(5000)
        expect(project.metadata["timezone"]).to eq("America/New_York")
        expect(project.metadata["screen_resolution"]).to eq("1920x1080")
        expect(project.metadata["form_interactions_count"]).to eq(3)
        expect(project.metadata["keystroke_count"]).to eq(42)
        expect(project.metadata["paste_count"]).to eq(1)
      end
    end

    context "when incomplete but with an image" do
      render_views

      before do
        post :create, params: { project: { new_photo_direct_upload_urls: ["http://example.com/test.png"] } }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template("new") }
    end

  end

  context "editing a project without saved question text" do
    render_views

    it "shows only saved questions, even when the chapter has added questions" do
      chapter = FactoryBot.create(:chapter, extra_question_2: "Chapter question?")
      project = FactoryBot.create(:project, chapter: chapter)
      sign_in_as FactoryBot.create(:user, admin: true)

      get :edit, params: { id: project }

      expect(response.body).not_to include("Chapter question?")
      expect(Nokogiri::HTML(response.body).at_css('[name="project[extra_question_1]"]')).to be_nil
      expect(project.reload.extra_question_1).to be_nil
    end
  end

  context "updating a project without a chapter parameter" do
    it "keeps the existing chapter" do
      project = FactoryBot.create(:project, extra_answer_2: "Answer without question")
      chapter = project.chapter
      sign_in_as FactoryBot.create(:user, admin: true)

      patch :update, params: { id: project, project: { title: "Updated project" } }

      expect(response).to be_redirect
      expect(project.reload.chapter).to eq(chapter)
      expect(project.title).to eq("Updated project")
      expect(project.extra_answer_2).to eq("Answer without question")
    end
  end

  context "moving an existing project to an inactive chapter" do
    it "allows the chapter change when saving an edit" do
      project = FactoryBot.create(:project)
      chapter = FactoryBot.create(:inactive_chapter)
      sign_in_as FactoryBot.create(:user, admin: true)

      patch :update, params: { id: project, chapter: chapter.slug, project: { title: "Updated project" } }

      expect(response).to be_redirect
      expect(project.reload.chapter).to eq(chapter)
    end
  end

  context "the project submission form" do
    let(:mode) { nil }

    context "with an inactive chapter" do
      render_views

      let(:chapter) { FactoryBot.create(:inactive_chapter) }

      it "shows chapter selection instead of an application" do
        get :new, params: { chapter: chapter.slug }
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('id="project_name"')
        expect(response.body).to include(I18n.t("projects.form.continue"))
      end

      it "returns not found for a stream request" do
        get :new, params: { chapter: chapter.slug }, format: :turbo_stream
        expect(response).to have_http_status(:not_found)
      end

      it "treats an embedded application like an invalid chapter" do
        expect {
          get :new, params: { chapter: chapter.slug, mode: "embed" }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "server-rendered chapter content" do
      render_views

      let(:chapter) { FactoryBot.create(:chapter, application_intro: "Chapter welcome", extra_question_1: "Chapter question?") }

      it "includes questions and intro in embedded HTML" do
        get :new, params: { chapter: chapter.slug, mode: "embed" }
        expect(response.body).to include("Chapter welcome", "Chapter question?", 'name="project[extra_question_1]"')
        expect(response.body).not_to include('class="project-section chapter-select"')
      end

      it "opens the application when a chapter link has trailing whitespace" do
        get :new, params: { locale: "nl", chapter: "#{chapter.slug} " }

        expect(response).to have_http_status(:ok)
        document = Nokogiri::HTML(response.body)
        expect(document.at_css('input[name="chapter"]')["value"]).to eq(chapter.slug)
        expect(document.at_css('#project_name')).to be_present
      end

      it "returns only targeted stream updates for chapter changes" do
        get :new, params: { chapter: chapter.slug }, format: :turbo_stream
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        document = Nokogiri::HTML.fragment(response.body)
        expect(document.css("turbo-stream").map { |stream| stream["target"] }).to eq(["application-chapter-intro", "application-chapter-questions"])
        expect(response.body).to include("Chapter question?", 'name="project[extra_answer_1]"', 'name="chapter"')
        expect(response.body).not_to include("project_name", "js-uploader")
      end

      it "populates nonblank chapter questions in order in the initial HTML" do
        chapter.update!(extra_question_1: "", extra_question_2: "Second slot?", extra_question_3: "Third slot?")
        get :new, params: { chapter: chapter.slug }
        document = Nokogiri::HTML(response.body)
        expect(document.at_css('input[name="project[extra_question_1]"]')["value"]).to eq("Second slot?")
        expect(document.at_css('input[name="project[extra_question_2]"]')["value"]).to eq("Third slot?")
      end

      it "returns a failure instead of streams for an unknown chapter" do
        get :new, params: { chapter: "unknown" }, format: :turbo_stream
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a chapter" do
      let(:chapter) { FactoryBot.create(:chapter) }

      before do
        get :new, params: { chapter: chapter.slug, mode: mode }
      end

      it { is_expected.to respond_with(:success) }

      context "in embed mode" do
        let(:mode) { "embed" }

        it { is_expected.to respond_with(:success) }
      end
    end

    context "with an invalid chapter" do
      it "displays successfully" do
        get :new, params: { chapter: "invalid" }

        expect(response.status).to eq(200)
      end

      context "in embed mode" do
        it "raises an exception if the Chapter is not set" do
          expect {
            get :new, params: { mode: "embed", chapter: "invalid" }
          }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "without a chapter" do
      before do
        get :new, params: { mode: mode }
      end

      it { is_expected.to respond_with(:success) }

      context "in embed mode" do
        let(:mode) { "embed" }

        it { is_expected.to respond_with(:missing) }
      end
    end
  end

  describe "#hide" do
    let(:user) { FactoryBot.create(:user) }
    let(:reason) { Faker::Company.bs }
    let(:project) { FactoryBot.create(:project) }
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
    let(:user) { FactoryBot.create(:user) }
    let(:reason) { Faker::Company.bs }
    let(:project) { FactoryBot.create(:project) }
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
