require 'spec_helper'

describe ModerationsController do
  let(:chapter) { FactoryBot.create(:chapter) }
  let(:any_chapter) { Chapter.any_chapter }
  let(:other_chapter) { FactoryBot.create(:chapter) }
  let(:project) { FactoryBot.create(:project, chapter: chapter) }
  let!(:project_moderation) { FactoryBot.create(:project_moderation, project: project) }
  let(:trustee) { FactoryBot.create(:user_with_trustee_role, chapters: [chapter]) }

  describe "GET #index" do
    context "when user is admin" do
      let(:admin) { FactoryBot.create(:admin) }

      before { sign_in_as(admin) }

      it "allows access to any chapter" do
        get :index, params: { chapter_id: chapter.slug }
        expect(response).to be_successful
      end

      it "allows access without chapter scope" do
        get :index
        expect(response).to be_successful
      end
    end

    context "when user is trustee" do
      before { sign_in_as(trustee) }

      it "allows access to their chapter" do
        get :index, params: { chapter_id: chapter.slug }
        expect(response).to be_successful
      end

      it "allows access to the Any chapter" do
        get :index, params: { chapter_id: any_chapter.slug }
        expect(response).to be_successful
      end

      it "denies access to other chapters" do
        get :index, params: { chapter_id: other_chapter.slug }
        expect(response).to have_http_status(:not_found)
      end

      it "denies access without chapter scope" do
        get :index
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not logged in" do
      it "redirects to sign in" do
        get :index
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe "POST #confirm_spam" do
    context "when user is admin" do
      let(:admin) { FactoryBot.create(:admin) }

      before { sign_in_as(admin) }

      it "allows moderating any project" do
        post :confirm_spam, params: { project_id: project.id }
        expect(response).to be_successful
      end
    end

    context "when user is a trustee" do
      before { sign_in_as(trustee) }

      it "allows moderating projects in their chapter" do
        post :confirm_spam, params: { project_id: project.id }
        expect(response).to be_successful
      end

      context "with Any chapter project" do
        let(:chapter) { Chapter.any_chapter }

        it "allows moderating projects in the Any chapter" do
          post :confirm_spam, params: { project_id: project.id }
          expect(response).to be_successful
        end
      end

      it "denies moderating projects in other chapters" do
        other_project = FactoryBot.create(:project, chapter: other_chapter)
        FactoryBot.create(:project_moderation, project: other_project)

        post :confirm_spam, params: { project_id: other_project.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #confirm_legit" do
    let(:fake_mailer) { FakeMailer.new }

    context "when user is a trustee" do
      before do
        sign_in_as(trustee)
        Project.any_instance.stubs(:mailer).returns(fake_mailer)
      end

      it "allows moderating projects in their chapter" do
        post :confirm_legit, params: { project_id: project.id }
        expect(response).to be_successful
        expect(fake_mailer).to have_delivered_email(:new_application)
      end

      context "with Any chapter project" do
        let(:chapter) { Chapter.any_chapter }

        it "allows moderating projects in the Any chapter" do
          post :confirm_legit, params: { project_id: project.id }
          expect(response).to be_successful
          expect(fake_mailer).to have_delivered_email(:new_application)
        end
      end

      it "denies moderating projects in other chapters" do
        other_project = FactoryBot.create(:project, chapter: other_chapter)
        FactoryBot.create(:project_moderation, project: other_project)

        post :confirm_legit, params: { project_id: other_project.id }
        expect(response).to have_http_status(:not_found)
        expect(fake_mailer).to_not have_delivered_email(:new_application)
      end
    end
  end

  describe "POST #undo" do
    context "when user is trustee" do
      before { sign_in_as(trustee) }

      it "allows undoing moderation for projects in their chapter" do
        post :undo, params: { project_id: project.id }
        expect(response).to be_successful
      end

      context "with Any chapter project" do
        let(:chapter) { Chapter.any_chapter }

        it "allows undoing moderation for projects in the Any chapter" do
          post :undo, params: { project_id: project.id }
          expect(response).to be_successful
        end
      end

      it "denies undoing moderation for projects in other chapters" do
        other_project = FactoryBot.create(:project, chapter: other_chapter)
        FactoryBot.create(:project_moderation, project: other_project)

        post :undo, params: { project_id: other_project.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
