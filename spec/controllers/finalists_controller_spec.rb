require 'spec_helper'

describe FinalistsController do
  context '#index' do
    let(:chapter) { FactoryBot.create(:chapter) }
    let(:project1) { FactoryBot.create(:project, chapter: chapter) }
    let(:project2) { FactoryBot.create(:project, chapter: chapter) }
    let(:funded_project) { FactoryBot.create(:winning_project, chapter: chapter) }
    let(:hidden_project) { FactoryBot.create(:hidden_project, chapter: chapter) }
    let(:trustee_role) { FactoryBot.create(:role, :trustee, chapter: chapter) }
    let(:past_trustee_role) { FactoryBot.create(:role, :trustee, chapter: chapter) }
    let!(:past_trustee) { past_trustee_role.user }
    let(:projects) { [project1, project2, funded_project, hidden_project] }

    before do
      Vote.create!(project: project1, user: trustee_role.user, chapter: chapter)
      Vote.create!(project: project2, user: past_trustee, chapter: chapter)
      Vote.create!(project: funded_project, user: trustee_role.user, chapter: chapter)
      Vote.create!(project: hidden_project, user: trustee_role.user, chapter: chapter)

      past_trustee_role.destroy

      sign_in_as trustee_role.user
    end

    render_views

    it "only shows projects voted on by current trustees, unfunded, unhidden by default" do
      get :index, params: { chapter_id: chapter }

      expect(response.body).to have_selector("tr.finalist[data-id='#{project1.id}']")
      expect(response.body).to_not have_selector("tr.finalist[data-id='#{project2.id}']")
      expect(response.body).to_not have_selector("tr.finalist[data-id='#{hidden_project.id}']")
      expect(response.body).to_not have_selector("tr.finalist[data-id='#{funded_project.id}']")
    end

    it "shows projects voted on by all trustees when the past_trustees param is set" do
      get :index, params: { chapter_id: chapter, past_trustees: "on" }

      expect(response.body).to have_selector("tr.finalist[data-id='#{project1.id}']")
      expect(response.body).to have_selector("tr.finalist[data-id='#{project2.id}']")
    end

    it "shows hidden projects when hidden filter is set" do
      get :index, params: { chapter_id: chapter, hidden: "on" }

      expect(response.body).to have_selector("tr.finalist[data-id='#{hidden_project.id}']")
    end

    it "shows funded projects when funded filter is set" do
      get :index, params: { chapter_id: chapter, funded: "on" }

      expect(response.body).to have_selector("tr.finalist[data-id='#{funded_project.id}']")
    end

    context "sorting" do
      it "sorts by title" do
        get :index, params: { chapter_id: chapter, past_trustees: "on", funded: "on", "hidden": "on", sort: "title" }

        expect(controller.view_assigns['projects'].collect { |p| p.id }).to eq(projects.sort { |a, b| a.title <=> b.title }.collect { |p| p.id })
      end

      it "sorts by creation date" do
        get :index, params: { chapter_id: chapter, past_trustees: "on", funded: "on", "hidden": "on", sort: "date" }

        expect(controller.view_assigns['projects'].collect { |p| p.id }).to eq(projects.sort { |a, b| b.created_at <=> a.created_at }.collect { |p| p.id })
      end
    end
  end
end
