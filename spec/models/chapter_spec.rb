require 'spec_helper'

describe Chapter do
  it { should have_many(:projects) }
  it { should have_many(:roles) }
  it { should have_many(:invitations) }
  it { should have_many(:users).through(:roles)}
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_uniqueness_of :name }

  context '.country_count' do
    let!(:chapter1){ FactoryGirl.create(:chapter, :country => "United States") }
    let!(:chapter2){ FactoryGirl.create(:chapter, :country => "BBB") }
    let!(:chapter3){ FactoryGirl.create(:chapter, :country => "United States") }
    it 'returns the number of unique countries we have chapters in' do
      Chapter.country_count.should == "2"
    end
  end

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

  context '.visitable' do
    let!(:chapter){ FactoryGirl.create(:chapter) }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'only returns chapters that are not the "Any" chapter' do
      Chapter.visitable.should == [chapter]
    end
  end

  context '.for_display' do
    let!(:z_chapter){ FactoryGirl.create(:chapter, :name => "ZZZ") }
    let!(:one_chapter){ FactoryGirl.create(:chapter, :name => "111") }
    let!(:a_chapter){ FactoryGirl.create(:chapter, :name => "AAA") }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'sorts alphabetically, but with "Any" in front' do
      Chapter.for_display.should == [any_chapter, one_chapter, a_chapter, z_chapter]
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

  context '.select_data' do
    let!(:a_chapter){ FactoryGirl.create(:chapter, :name => "AAA") }
    let!(:z_chapter){ FactoryGirl.create(:chapter, :name => "ZZZ") }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'sorts alphabetically with Any chapter first' do
      Chapter.select_data.should == [any_chapter, a_chapter, z_chapter]
    end
  end

end
