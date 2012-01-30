require 'spec_helper'

describe User do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:encrypted_password) }
  it { should have_many(:roles) }
  it { should have_many(:chapters).through(:roles) }

  context "#can_manage_chapter?" do
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:user) { FactoryGirl.create(:user) }
    let(:role) { FactoryGirl.create(:role, :user => user, :chapter => chapter) }

    it 'returns true when the Role is a Dean role' do
      role.update_attribute(:name, "dean")
      user.can_manage_chapter?(chapter).should be_true
    end

    it 'returns false when the Role is a trustee role' do
      role.update_attribute(:name, "trustee")
      user.can_manage_chapter?(chapter).should be_false
    end

    it 'returns true if the use is an admin' do
      role.destroy
      user.admin = true
      user.can_manage_chapter?(chapter).should be_true
    end

    it 'returns false if the user is not affiliated with the chapter' do
      role.destroy
      user.can_manage_chapter?(chapter).should be_false
    end
  end
end
