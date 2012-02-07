require 'spec_helper'

describe ChaptersHelper do

  let!(:role) { FactoryGirl.create(:role, :name => 'dean') }
  let!(:user) { role.user }
  let!(:chapter) { role.chapter }

  it 'checks if user can manage a chapter' do
    helper.stubs(:current_user).returns(user)
    helper.can_manage_chapter?(chapter).should == true
  end

end
