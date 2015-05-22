require 'spec_helper'

describe HomeController do
  render_views

  context 'displaying the homepage' do
    let!(:chapter) { FactoryGirl.create(:chapter) }
    let!(:inactive) { FactoryGirl.create(:inactive_chapter) }

    before do
      get :index
    end

    it 'should not include inactive chapters in the total chapter count' do
      response.body.should have_selector('section.who-where', :text => '1 Chapter')
    end

    it 'should not include inactive chapters in the chapter list' do
      response.body.should_not have_selector('section.awesome-chapters', :text => inactive.name)
    end

    it 'should include active chapters in the chapter list' do
      response.body.should have_selector('section.awesome-chapters', :text => chapter.name)
    end
  end
end
