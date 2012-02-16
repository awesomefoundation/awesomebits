require 'spec_helper'

describe ChaptersHelper do

  let!(:role) { FactoryGirl.create(:role, :name => 'dean') }
  let!(:user) { role.user }
  let!(:chapter) { role.chapter }

  it 'checks if authorized user can manage a chapter' do
    helper.stubs(:current_user).returns(user)
    helper.can_manage_chapter?(chapter).should == true
  end

  it 'checks if un-authorized user can manage a chapter ' do
    helper.stubs(:current_user).returns(nil)
    helper.can_manage_chapter?(chapter).should == false
  end

  it 'returns an array of headlines from chapter feed' do
    rss_feed_url = Rails.root.join('spec', 'support', 'feed.xml')
    helper.headlines(rss_feed_url).should be_an_instance_of Array
    helper.headlines(rss_feed_url).should have(1).things
  end

end
