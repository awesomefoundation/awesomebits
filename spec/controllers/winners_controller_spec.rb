require 'spec_helper'

describe WinnersController do
  let(:other_chapter) { FactoryGirl.create(:chapter) }

  before do
    sign_in_as(user) if defined?(user)
  end

  context "user is not logged in" do
    let(:project) { FactoryGirl.create(:project) }

    it "redirects when trying to view the edit page" do
      get :edit, params: { chapter_id: project.chapter_id, project_id: project.id }

      expect(response.status).to eq(302)
      expect(response).to redirect_to(sign_in_path)
      expect(flash[:alert]).to eq(I18n.t("flashes.failure_when_not_signed_in"))
    end
  end

  context "a dean is logged in" do
    let(:user) { FactoryGirl.create(:user_with_dean_role) }

    context "a project is in a real chapter" do
      let(:project) { FactoryGirl.create(:project) }

      it "cannot set the winner for another chapter" do
        post :create, params: { project_id: project.id, chapter_id: other_chapter.id }

        expect(project.reload.winner?).to be false
        expect(flash[:notice]).not_to be_blank
      end
    end

    context "a project is in the Any chapter" do
      let(:project) { FactoryGirl.create(:project, chapter: Chapter.find_by_name('Any')) }

      it "cannot set the winner for another chapter" do
        post :create, params: { project_id: project.id, chapter_id: other_chapter.id }

        expect(project.reload.winner?).to be false
        expect(flash[:notice]).not_to be_blank
      end
    end
  end

  context "an admin is logged in" do
    let(:user) { FactoryGirl.create(:admin) }

    context "a project is in a real chapter" do
      let(:project) { FactoryGirl.create(:project) }

      it "can set the winner for another chapter" do
        post :create, params: { project_id: project.id, chapter_id: other_chapter.id }

        expect(project.reload.winner?).to be true
        expect(flash[:notice]).to be_blank
      end
    end

    context "a project is in the Any chapter" do
      let(:project) { FactoryGirl.create(:project, chapter: Chapter.find_by_name('Any')) }

      it "can set the winner for another chapter" do
        post :create, params: { project_id: project.id, chapter_id: other_chapter.id }

        expect(project.reload.winner?).to be true
        expect(flash[:notice]).to be_blank
      end
    end
  end
end
