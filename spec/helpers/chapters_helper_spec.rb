require 'spec_helper'

describe ChaptersHelper, '#can_manage_chapter?' do

  let!(:role) { FactoryGirl.create(:role, :name => 'dean') }
  let!(:user) { role.user }
  let!(:chapter) { role.chapter }

  it 'checks if authorized user can manage a chapter' do
    helper.stubs(:current_user).returns(user)
    expect(helper.can_manage_chapter?(chapter)).to eq(true)
  end

  it 'checks if un-authorized user can manage a chapter ' do
    helper.stubs(:current_user).returns(nil)
    expect(helper.can_manage_chapter?(chapter)).to eq(false)
  end

end

describe ChaptersHelper, '#link_if_not_blank' do

  let!(:chapter) { FactoryGirl.create(:chapter, twitter_url: "http://twitter.com/awesomefound")}

  it 'returns nil if the url is not present' do
    expect(helper.link_if_not_blank(chapter.facebook_url, "classes")).to be_nil
  end

  it 'returns a link if the url is present' do
    expected_value = helper.link_to("", "http://twitter.com/awesomefound", class: "classes")
    expect(helper.link_if_not_blank(chapter.twitter_url, "classes")).to eq(expected_value)
  end

end

describe ChaptersHelper, '#email_link' do
  
  context "when email is blank" do 
    let!(:chapter) { FactoryGirl.create(:chapter) }
    it { expect(helper.email_link(chapter)).to be_nil }
  end

  context "when email is present" do
    let!(:chapter) { FactoryGirl.create(:chapter, email_address: "chapter@example.com") }
    it { expect(helper.email_link(chapter)).not_to be_nil }
  end

end
