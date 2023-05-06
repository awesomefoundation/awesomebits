require 'spec_helper'

describe FinalistsController do
  context '#index' do
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:project1) { FactoryGirl.create(:project, chapter: chapter) }
    let(:project2) { FactoryGirl.create(:project, chapter: chapter) }
    let(:funded_project) { FactoryGirl.create(:winning_project, chapter: chapter) }
    let(:hidden_project) { FactoryGirl.create(:hidden_project, chapter: chapter) }
    let(:trustee_role) { FactoryGirl.create(:role, :trustee, chapter: chapter) }
    let(:past_trustee_role) { FactoryGirl.create(:role, :trustee, chapter: chapter) }
    let!(:past_trustee) { past_trustee_role.user }

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
  end
end
