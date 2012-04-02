require 'spec_helper'

describe ProjectsHelper, 'selectable_chapters_for' do

  let!(:admin) { create :admin }
  let!(:user) { create :user }
  let!(:any_chapter) { Chapter.find_by_name 'Any' }
  let!(:boston_chapter) { create :chapter, :name => 'Boston' }
  let!(:nyc_chapter) { create :chapter, :name => 'NYC' }
  let!(:role) { create :role, :user => user, :chapter => boston_chapter }

  it 'should return all chapters for admin user' do
    helper.selectable_chapters_for(admin).should == [any_chapter, boston_chapter, nyc_chapter]
  end

  it 'should return only user chapters for non-admin user' do
    helper.selectable_chapters_for(user).should == [any_chapter, boston_chapter]
  end

end
