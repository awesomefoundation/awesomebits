require 'spec_helper'

describe HomeController do
  render_views

  context 'displaying the homepage' do
    let!(:chapter) { FactoryGirl.create(:chapter, :country => "United States") }
    let!(:inactive) { FactoryGirl.create(:inactive_chapter, :country => "Canada") }

    before do
      get :index
    end

    it 'should not include inactive chapters in the total chapter count' do
      response.body.should have_selector('section.who-where', :text => '1 Chapter')
    end

    it 'should not include inactive chapters in the total country count' do
      response.body.should have_selector('section.who-where', :text => '1 Countr')
    end

    it 'should not include inactive chapters in the chapter list' do
      response.body.should_not have_selector('section.awesome-chapters', :text => inactive.name)
    end

    it 'should include active chapters in the chapter list' do
      response.body.should have_selector('section.awesome-chapters', :text => chapter.name)
    end
  end

  context 'getting an Atom feed of winning projects' do
    let!(:chapter) { FactoryGirl.create(:chapter, country: 'United States') }

    before do
      get :feed, format: :xml
    end

    it 'should return parseable XML' do
      response.content_type.should eq('application/xml')
      lambda { Nokogiri::XML(response.body) }.should_not raise_error
    end
  end
end
