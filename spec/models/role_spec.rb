require 'spec_helper'

describe Role do
  it { should belong_to :user }
  it { should belong_to :chapter }

  it '#trustee? always returns true' do
    Role.new.trustee?.should == true
  end

  context '#dean?' do
    let(:role) { FactoryGirl.build(:role) }
    it 'returns true if this is a dean role' do
      role.name = "dean"
      role.dean?.should be_true
    end

    it 'returns false if the user is only a trustee' do
      role.name = 'trustee'
      role.dean?.should be_false
    end
  end

end
