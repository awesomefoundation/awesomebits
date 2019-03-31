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
      expect(response.body).to have_selector('section.who-where', :text => '1 Chapter')
    end

    it 'should not include inactive chapters in the total country count' do
      expect(response.body).to have_selector('section.who-where', :text => '1 Countr')
    end

    it 'should not include inactive chapters in the chapter list' do
      expect(response.body).not_to have_selector('section.awesome-chapters', :text => inactive.name)
    end

    it 'should include active chapters in the chapter list' do
      expect(response.body).to have_selector('section.awesome-chapters', :text => chapter.name)
    end
  end

  context 'with an invalid locale' do
    it 'should use the default locale' do
      get :index, params: { locale: 'INVALID LOCALE' }

      expect(I18n.locale).to eq(I18n.default_locale)
    end
  end
end
