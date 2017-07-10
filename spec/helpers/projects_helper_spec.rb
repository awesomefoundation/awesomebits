require 'spec_helper'

describe ProjectsHelper, '#selectable_chapters_for' do
  let!(:admin) { FactoryGirl.create :admin }
  let!(:user) { FactoryGirl.create :user }
  let!(:any_chapter) { Chapter.find_by_name 'Any' }
  let!(:boston_chapter) { FactoryGirl.create :chapter, :name => 'Boston' }
  let!(:nyc_chapter) { FactoryGirl.create :chapter, :name => 'NYC' }
  let!(:role) { FactoryGirl.create :role, :user => user, :chapter => boston_chapter }

  it 'should return all chapters for admin user' do
    expect(helper.selectable_chapters_for(admin)).to eq([any_chapter, boston_chapter, nyc_chapter])
  end

  it 'should return only user chapters for non-admin user' do
    expect(helper.selectable_chapters_for(user)).to eq([any_chapter, boston_chapter])
  end
end

describe ProjectsHelper, '#checked_attribute_if' do
  it 'returns an empty string for falsy' do
    expect(helper.checked_attribute_if(nil)).to eq('')
    expect(helper.checked_attribute_if(false)).to eq('')
  end

  it 'returns a correct checked attribute for truthy' do
    expect(helper.checked_attribute_if(true)).to eq('checked="checked"')
  end

  it 'returns an HTML-safe string for truthy' do
    expect(helper.checked_attribute_if(true)).to be_html_safe
  end
end

