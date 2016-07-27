require 'spec_helper'

describe Chapter do
  it { should have_many(:projects) }
  it { should have_many(:roles) }
  it { should have_many(:invitations) }
  it { should have_many(:users).through(:roles)}
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_uniqueness_of :name }
  it { should_not allow_value("invalid slug").for(:slug) }
  it { should_not allow_value("Invalid-Slug").for(:slug) }
  it { should allow_value("valid-slug1").for(:slug) }

  context '.country_count' do
    let!(:chapter1){ FactoryGirl.create(:chapter, :country => "United States") }
    let!(:chapter2){ FactoryGirl.create(:chapter, :country => "BBB") }
    let!(:chapter3){ FactoryGirl.create(:chapter, :country => "United States") }
    it 'returns the number of unique countries we have chapters in' do
      Chapter.country_count.should == "2"
    end
  end

  context "slug generation" do
    it "happens when the record is new" do
      chapter = FactoryGirl.build(:chapter, :slug => "", :name => "Foo")
      chapter.slug.should be_blank
      chapter.save
      chapter.slug.should == "foo"
    end

    it "happens when the slug is blank" do
      chapter = FactoryGirl.create(:chapter, :name => "Foo")
      chapter.slug.should == "foo"
      chapter.slug = nil
      chapter.save
      chapter.slug.should == "foo"
    end

    it "doesn't happen when the slug is manually set" do
      chapter = FactoryGirl.build(:chapter, :name => "Foo")
      chapter.slug = "this-is-a-slug"
      chapter.save
      chapter.slug.should == "this-is-a-slug"
    end
  end

  context '.winning_projects' do
    it 'returns projects in descending order of funded_on' do
      Timecop.freeze(Time.now) do
        chapter = FactoryGirl.create(:chapter)
        project1 = FactoryGirl.create(:project, chapter: chapter, funded_on: 1.week.ago)
        project2 = FactoryGirl.create(:project, chapter: chapter, funded_on: 1.year.ago)
        project3 = FactoryGirl.create(:project, chapter: chapter, funded_on: 1.month.ago)

        chapter.winning_projects.should == [project1, project3, project2]
      end
    end
  end

  context '.invitable_by for deans' do
    let!(:role) { FactoryGirl.create(:role, :name => 'dean')}
    let!(:chapter) {role.chapter}
    let!(:user) {role.user}
    let!(:no_chapter) { FactoryGirl.create(:chapter)}
    let!(:trustee_chapter) { FactoryGirl.create(:role, :name => 'trustee', :user => user)}
    it 'returns chapters user can invite to' do
      Chapter.invitable_by(user).should == [chapter]
    end
  end

  context '.invitable_by for admin' do
    let!(:chapter) { FactoryGirl.create(:chapter)}
    let!(:user) { FactoryGirl.create(:user, :admin => true)}
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
      FactoryGirl.build(:chapter, :name => "Any").any_chapter?.should be_truthy
    end
    it 'returns false if the name of this chapter is "Any"' do
      FactoryGirl.build(:chapter, :name => "XXX").any_chapter?.should be_falsey
    end
  end

  context '.current_chapter_for_user' do
    it 'returns first chapter with membership for an admin user who has chapters' do
      FactoryGirl.create(:chapter)
      admin = FactoryGirl.create(:user, :admin => true)
      chapter = FactoryGirl.create(:chapter)
      FactoryGirl.create(:role, :user => admin, :chapter => chapter)

      Chapter.current_chapter_for_user(admin).should == chapter
    end
    it 'returns first overall chapter for admin user without any chapters' do
      admin = FactoryGirl.create(:user, :admin => true)
      FactoryGirl.create(:chapter)
      FactoryGirl.create(:chapter)

      Chapter.current_chapter_for_user(admin).should == Chapter.first
    end
    it 'returns first member chapter for a trustee' do
      FactoryGirl.create(:chapter)
      trustee = FactoryGirl.create(:user)
      chapter = FactoryGirl.create(:chapter)
      FactoryGirl.create(:role, :user => trustee, :chapter => chapter)
      Chapter.current_chapter_for_user(trustee).should == chapter
    end
    it 'returns nil for a user with no chapters' do
      user = FactoryGirl.create(:user)
      user.chapters.should == []
      Chapter.current_chapter_for_user(user).should be_nil
    end
  end

  context '.name' do
    it 'returns the name for an active chapter' do
      chapter = FactoryGirl.build(:chapter, :name => 'Active Chapter')

      chapter.name.should == 'Active Chapter'
    end

    it 'indicates that an inactive chapter is Inactive' do
      chapter = FactoryGirl.build(:inactive_chapter, :name => 'Inactive Chapter')

      chapter.name.should == 'Inactive Chapter (Inactive)'
    end
  end
end
