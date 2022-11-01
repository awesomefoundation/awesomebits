require 'spec_helper'

describe FundedProjectsController do
  context 'getting an Atom feed of winning projects' do
    render_views

    let!(:chapter) { FactoryGirl.create(:chapter, country: 'United States') }
    let!(:project) { FactoryGirl.create(:winning_project, chapter: chapter) }
    let!(:image) { FactoryGirl.create(:photo, project: project) }

    before do
      get :index, format: :xml
    end

    it 'should return parseable XML' do
      expect(response.media_type).to eq('application/xml')
      expect { Nokogiri::XML(response.body) }.not_to raise_error
    end
  end

  context 'making an HTML request' do
    render_views

    let!(:chapter) { FactoryGirl.create(:chapter, slug: 'nyc', name: 'New York City') }
    let!(:winner) { FactoryGirl.create(:winning_project, chapter: chapter) }

    before do
      9.times do
        FactoryGirl.create(:winning_project)
      end
    end

    it 'should return all the projects' do
      get :index
      expect(response.body.scan("project-with-image__project-name").size).to eq(10)
    end

    it 'should return only the projects for a chapter' do
      get :index, params: { chapter: chapter.slug }
      expect(response.body.scan("project-with-image__project-name").size).to eq(1)
    end
  end

  context 'viewing a project that has won while logged out' do
    let!(:project) { FactoryGirl.create(:project, funded_on: Date.today) }

    context "with the correct slug" do
      before do
        get :show, params: { id: project, locale: I18n.locale }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template("show") }
    end

    context "with an incorrect slug" do
      before do
        get :show, params: { id: "#{project.id}-this-is-a-bad-slug", locale: I18n.locale }
      end

      it { is_expected.to respond_with(:moved_permanently) }
      it { is_expected.to redirect_to(funded_project_path(project)) }
    end
  end

  context 'viewing a public project page that has not won yet' do
    let!(:project) { FactoryGirl.create(:project) }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:role) { FactoryGirl.create(:role, user: user) }

    context 'while logged in' do
      before do
        sign_in_as user
        get :show, params: { id: project }
      end
      it { is_expected.to respond_with(:redirect) }
      it { is_expected.to redirect_to(chapter_project_path(project.chapter, project)) }
    end

    context 'while not logged in' do
      before do
        sign_out
        get :show, params: { id: project }
      end
      it { is_expected.to respond_with(:missing) }
    end
  end
end
