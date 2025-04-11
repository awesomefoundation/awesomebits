require 'spec_helper'

describe 'finalists/index' do
  let!(:user) { FactoryBot.create(:user_with_dean_role) }
  let!(:project1) { FactoryBot.create(:project, chapter: user.chapters.first) }
  let!(:project2) { FactoryBot.create(:project) }

  before(:each) do
    controller.request.params[:chapter_id] = project1.chapter
  end

  describe 'when a project from another chapter has votes from our trustees' do
    it 'displays the name of the other chapter next to that project title' do
      Vote.create(user: user, project: project1, chapter: project1.chapter)
      Vote.create(user: user, project: project2, chapter: project1.chapter)

      assign(:chapter, project1.chapter)
      assign(:projects, Project.with_votes_for_chapter(project1.chapter).by_vote_count)
      view.stubs(:current_user).returns(user)

      render

      expect(rendered).not_to have_css("tr[data-id=\"#{project1.id}\"] td em", text: project1.chapter.display_name)
      expect(rendered).to have_css("tr[data-id=\"#{project2.id}\"] td em", text: project2.chapter.display_name)
    end
  end
end
