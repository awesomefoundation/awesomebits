require 'spec_helper'

describe 'shared/_navigation' do
  let!(:chapter) { FactoryGirl.create(:chapter) }
  let!(:inactive_chapter) { FactoryGirl.create(:inactive_chapter) }

  it 'only displays active chapters in the chapter list' do
    view.stubs(:signed_in?).returns(false)

    render

    expect(rendered).to     have_content(chapter.name)
    expect(rendered).not_to have_content(inactive_chapter.name)
  end
end
