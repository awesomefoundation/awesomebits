require 'spec_helper'

describe User do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:encrypted_password) }
  it { should have_many(:roles) }
  it { should have_many(:chapters).through(:roles) }

  context "#trustee?" do
    let(:user){ FactoryGirl.build(:user) }
    let(:chapter){ FactoryGirl.build(:chapter) }
    let(:role){ FactoryGirl.build(:role, :user => user, :chapter => chapter) }
    before do
      user.roles = [role]
    end

    it 'returns true if the user is a trustee anywhere' do
      user.trustee?.should be_true
    end

    it 'returns false if the user is not a trustee anywhere' do
      user.roles = []
      user.trustee?.should be_false
    end

    it 'returns true if the user is only a dean somewhere' do
      role.name = "dean"
      user.trustee?.should be_true
    end

    it 'returns true if the user is an admin' do
      user.admin = true
      user.roles = []
      user.trustee?.should be_true
    end
  end

  context '#can_invite?' do
    let(:user) { FactoryGirl.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_invite?.should be_true
    end
    it 'asks the roles if it can invite if not an admin' do
      user.admin = false
      user.roles.stubs(:can_invite?)
      user.can_invite?
      user.roles.should have_received(:can_invite?)
    end
  end

  context '#can_invite_to_chapter?' do
    let(:user) { FactoryGirl.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_invite_to_chapter?(:chapter).should be_true
    end
    it 'asks the roles if it can invite if not an admin' do
      user.admin = false
      user.roles.stubs(:can_invite_to_chapter?)
      user.can_invite_to_chapter?(:chapter)
      user.roles.should have_received(:can_invite_to_chapter?)
    end
  end

  context "#can_manage_chapter?" do
    let(:user) { FactoryGirl.build(:user) }
    it 'returns true if the user is an admin' do
      user.admin = true
      user.can_manage_chapter?(:chapter).should be_true
    end
    it 'asks the roles if it can manage if not an admin' do
      user.admin = false
      user.roles.stubs(:can_manage_chapter?)
      user.can_manage_chapter?(:chapter)
      user.roles.should have_received(:can_manage_chapter?)
    end
  end


end
