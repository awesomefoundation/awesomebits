require 'spec_helper'

describe Chapter do
  it { should have_many(:projects) }
  it { should have_many(:roles) }
  it { should have_many(:invitations) }
  it { should have_many(:users).through(:roles)}
  context '.invitable_by for deans' do
    let!(:role) {FactoryGirl.create(:role, :name => 'dean')}
    let!(:chapter) {role.chapter}
    let!(:user) {role.user}
    let!(:no_chapter) {FactoryGirl.create(:chapter)}
    let!(:trustee_chapter) {FactoryGirl.create(:role, :name => 'trustee', :user => user)}
    it 'returns chapters user can invite to' do
      Chapter.invitable_by(user).should == [chapter]
    end
  end
  context '.invitable_by for admin' do
    let!(:chapter) {FactoryGirl.create(:chapter)}
    let!(:user) {FactoryGirl.create(:user, :admin => true)}
    it 'returns chapters admin can invite to' do
      Chapter.invitable_by(user).should == [chapter]
    end
  end

  context '#any_chapter?' do
    it 'returns true if the name of this chapter is "Any"' do
      FactoryGirl.build(:chapter, :name => "Any").any_chapter?.should be_true
    end
    it 'returns false if the name of this chapter is "Any"' do
      FactoryGirl.build(:chapter, :name => "XXX").any_chapter?.should be_false
    end
  end
end
