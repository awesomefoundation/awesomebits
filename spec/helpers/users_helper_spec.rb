require 'spec_helper'

describe UsersHelper, '#view_all_users?' do

  it 'returns true when there is no chapter_id in params' do
    params = {}
    helper.stubs(:params).returns(params)
    helper.view_all_users?.should be_true
  end

  it 'returns false when there is no chapter_id in params' do
    params = { :chapter_id => 123 }
    helper.stubs(:params).returns(params)
    helper.view_all_users?.should be_false
  end

end
