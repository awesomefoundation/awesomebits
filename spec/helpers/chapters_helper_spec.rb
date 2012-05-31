require 'spec_helper'

describe ChaptersHelper, '#can_manage_chapter?' do

  let!(:role) { create(:role, :name => 'dean') }
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

end

describe ChaptersHelper, '#link_if_not_blank' do

  let!(:chapter) {create(:chapter, twitter_url: "http://twitter.com/awesomefound")}

  it 'returns nil if the url is not present' do
    helper.link_if_not_blank(chapter.facebook_url, "classes").should be_nil
  end

  it 'returns a link if the url is present' do
    expected_value = helper.link_to("", "http://twitter.com/awesomefound", class: "classes")
    helper.link_if_not_blank(chapter.twitter_url, "classes").should == expected_value
  end

end
