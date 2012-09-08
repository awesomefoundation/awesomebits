require 'spec_helper'

describe 'chapters/show' do 
  let!(:chapter) { create(:chapter) }

  it 'renders an apply button in the header' do
    assign(:chapter, chapter)
    view.stubs(:current_user).returns(nil)

    render
    rendered.should have_selector('header div.title a.apply-chapter', :text => t('chapters.show.apply-for-grant'))
  end

  it 'renders an apply button at the bottom of the page' do 
    assign(:chapter, chapter)
    view.stubs(:current_user).returns(nil)

    render
    rendered.should have_selector('section.chapter-apply a', :text => t('chapters.show.apply-for-grant'))
  end
end
