require 'spec_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project) }
  let(:comment) { FactoryBot.create(:comment, project: project, user: user) }
  let(:other_comment) { FactoryBot.create(:comment, project: project) }

  context "when not logged in" do
    it "can't create a new comment" do
      post :create, params: { project_id: project.id, comment: { body: "comment body" } }

      expect(response).to redirect_to(root_url)
    end

    it "can't delete a comment" do
      post :destroy, params: { project_id: comment.project.id, id: comment.id }

      expect(response).to redirect_to(root_url)
    end
  end

  context "logged in as a trustee" do
    before do
      sign_in_as user
    end

    it "creates a comment" do
      post :create, params: { project_id: project.id, comment: { body: "comment" } }

      expect(response.status).to eq(200)
    end

    it "can't create a comment without a body" do
      post :create, params: { project_id: project.id, comment: { body: "" } }

      expect(response.status).to eq(400)
    end

    it "deletes its own comment" do
      post :destroy, params: { project_id: comment.project.id, id: comment.id }

      expect(response.status).to eq(200)
    end

    it "can't delete someone else's comment" do
      post :destroy, params: { project_id: other_comment.project.id, id: other_comment.id }

      expect(response).to have_http_status(:forbidden)
    end
  end

  context "logged in as a dean" do
    let(:dean) { FactoryBot.create(:user_with_dean_role) }
    let(:project) { FactoryBot.create(:project, chapter: dean.chapters.first) }
    let(:other_chapter_comment) { FactoryBot.create(:comment) }

    before do
      sign_in_as dean
    end

    it "deletes a comment from another chapter user" do
      post :destroy, params: { project_id: comment.project.id, id: comment.id }

      expect(response.status).to eq(200)
    end

    it "can't delete someone else's comment" do
      post :destroy, params: { project_id: other_chapter_comment.project.id, id: other_chapter_comment.id }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
