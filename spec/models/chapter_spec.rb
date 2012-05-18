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
    let!(:chapter1){ create(:chapter, :country => "United States") }
    let!(:chapter2){ create(:chapter, :country => "BBB") }
    let!(:chapter3){ create(:chapter, :country => "United States") }
    it 'returns the number of unique countries we have chapters in' do
      Chapter.country_count.should == "2"
    end
  end

  context '.invitable_by for deans' do
    let!(:role) {create(:role, :name => 'dean')}
    let!(:chapter) {role.chapter}
    let!(:user) {role.user}
    let!(:no_chapter) {create(:chapter)}
    let!(:trustee_chapter) {create(:role, :name => 'trustee', :user => user)}
    it 'returns chapters user can invite to' do
      Chapter.invitable_by(user).should == [chapter]
    end
  end

  context '.invitable_by for admin' do
    let!(:chapter) {create(:chapter)}
    let!(:user) {create(:user, :admin => true)}
    it 'returns chapters admin can invite to' do
      Chapter.invitable_by(user).should == [chapter]
    end
  end

  context '.visitable' do
    let!(:chapter){ create(:chapter) }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'only returns chapters that are not the "Any" chapter' do
      Chapter.visitable.should == [chapter]
    end
  end

  context '.for_display' do
    let!(:z_chapter){ create(:chapter, :name => "ZZZ") }
    let!(:one_chapter){ create(:chapter, :name => "111") }
    let!(:a_chapter){ create(:chapter, :name => "AAA") }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'sorts alphabetically, but with "Any" in front' do
      Chapter.for_display.should == [any_chapter, one_chapter, a_chapter, z_chapter]
    end
  end

  context '#any_chapter?' do
    it 'returns true if the name of this chapter is "Any"' do
      build(:chapter, :name => "Any").any_chapter?.should be_true
    end
    it 'returns false if the name of this chapter is "Any"' do
      build(:chapter, :name => "XXX").any_chapter?.should be_false
    end
  end

  context '.current_chapter_for_user' do
    it 'returns first chapter for admin user' do
      admin = create(:user, :admin => true)
      create(:chapter)
      create(:chapter)

      Chapter.current_chapter_for_user(admin).should == Chapter.first
    end
    it 'returns first chapter for trustee' do
      create(:chapter)
      trustee = create(:user)
      chapter = create(:chapter)
      create(:role, :user => trustee, :chapter => chapter)
      Chapter.current_chapter_for_user(trustee).should == chapter
    end
    it 'returns nil for user with no chapters' do
      user = create(:user)
      user.chapters.should == []
      Chapter.current_chapter_for_user(user).should be_nil
    end
  end
end
