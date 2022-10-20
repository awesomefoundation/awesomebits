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
      expect(response.content_type).to eq('application/xml')
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
end
