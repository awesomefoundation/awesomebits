require 'spec_helper'

describe WinnersController do
  let(:user) { FactoryGirl.create(:user_with_dean_role) }
  let(:other_chapter) { FactoryGirl.create(:chapter) }

  before do
    sign_in_as user
  end

  context "a project is in a real chapter" do
    let(:project) { FactoryGirl.create(:project) }

    it "cannot set the winner for another chapter by a dean" do
      post :create, :project_id => project.id, :chapter_id => other_chapter.id

      expect(project.reload.winner?).to be false
      expect(flash[:notice]).not_to be_blank
    end
  end

  context "a project is in the Any chapter" do
    let(:project) { FactoryGirl.create(:project, :chapter => Chapter.find_by_name('Any')) }

    it "cannot set the winner for another chapter by a dean" do
      post :create, :project_id => project.id, :chapter_id => other_chapter.id

      expect(project.reload.winner?).to be false
      expect(flash[:notice]).not_to be_blank
    end
  end
end
