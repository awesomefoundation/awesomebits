require 'spec_helper'

describe Chapter do
  it { is_expected.to have_many(:projects) }
  it { is_expected.to have_many(:roles) }
  it { is_expected.to have_many(:invitations) }
  it { is_expected.to have_many(:users).through(:roles)}
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_uniqueness_of :name }
  it { is_expected.not_to allow_value("invalid slug").for(:slug) }
  it { is_expected.not_to allow_value("Invalid-Slug").for(:slug) }
  it { is_expected.to allow_value("valid-slug1").for(:slug) }

  context '.country_count' do
    let!(:chapter1){ FactoryGirl.create(:chapter, :country => "United States") }
    let!(:chapter2){ FactoryGirl.create(:chapter, :country => "Canada") }
    let!(:chapter3){ FactoryGirl.create(:chapter, :country => "United States") }
    it 'returns the number of unique countries we have chapters in' do
      expect(Chapter.country_count).to eq(2)
    end

    it 'ignores "Worldwide" chapters' do
      FactoryGirl.create(:chapter, :country => "Worldwide")
      expect(Chapter.country_count).to eq(2)
    end
  end

  context "slug generation" do
    it "happens when the record is new" do
      chapter = FactoryGirl.build(:chapter, :slug => "", :name => "Foo")
      expect(chapter.slug).to be_blank
      chapter.save
      expect(chapter.slug).to eq("foo")
    end

    it "happens when the slug is blank" do
      chapter = FactoryGirl.create(:chapter, :name => "Foo")
      expect(chapter.slug).to eq("foo")
      chapter.slug = nil
      chapter.save
      expect(chapter.slug).to eq("foo")
    end

    it "doesn't happen when the slug is manually set" do
      chapter = FactoryGirl.build(:chapter, :name => "Foo")
      chapter.slug = "this-is-a-slug"
      chapter.save
      expect(chapter.slug).to eq("this-is-a-slug")
    end
  end

  context '.winning_projects' do
    it 'returns projects in descending order of funded_on' do
      Timecop.freeze(Time.now) do
        chapter = FactoryGirl.create(:chapter)
        project1 = FactoryGirl.create(:project, chapter: chapter, funded_on: 1.week.ago)
        project2 = FactoryGirl.create(:project, chapter: chapter, funded_on: 1.year.ago)
        project3 = FactoryGirl.create(:project, chapter: chapter, funded_on: 1.month.ago)

        expect(chapter.winning_projects).to eq([project1, project3, project2])
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
      expect(Chapter.invitable_by(user)).to eq([chapter])
    end
  end

  context '.invitable_by for admin' do
    let!(:chapter) { FactoryGirl.create(:chapter)}
    let!(:user) { FactoryGirl.create(:user, :admin => true)}
    it 'returns chapters admin can invite to' do
      expect(Chapter.invitable_by(user)).to eq([chapter])
    end
  end

  context '.visitable' do
    let!(:chapter){ FactoryGirl.create(:chapter) }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'only returns chapters that are not the "Any" chapter' do
      expect(Chapter.visitable).to eq([chapter])
    end
  end

  context '.for_display' do
    let!(:z_chapter){ FactoryGirl.create(:chapter, :name => "ZZZ") }
    let!(:one_chapter){ FactoryGirl.create(:chapter, :name => "111") }
    let!(:a_chapter){ FactoryGirl.create(:chapter, :name => "AAA") }
    let!(:any_chapter){ Chapter.find_by_name("Any") }
    it 'sorts alphabetically, but with "Any" in front' do
      expect(Chapter.for_display).to eq([any_chapter, one_chapter, a_chapter, z_chapter])
    end
  end

  context '#any_chapter?' do
    it 'returns true if the name of this chapter is "Any"' do
      expect(FactoryGirl.build(:chapter, :name => "Any").any_chapter?).to be_truthy
    end
    it 'returns false if the name of this chapter is "Any"' do
      expect(FactoryGirl.build(:chapter, :name => "XXX").any_chapter?).to be_falsey
    end
  end

  context '.current_chapter_for_user' do
    it 'returns first chapter with membership for an admin user who has chapters' do
      FactoryGirl.create(:chapter)
      admin = FactoryGirl.create(:user, :admin => true)
      chapter = FactoryGirl.create(:chapter)
      FactoryGirl.create(:role, :user => admin, :chapter => chapter)

      expect(Chapter.current_chapter_for_user(admin)).to eq(chapter)
    end
    it 'returns first overall chapter for admin user without any chapters' do
      admin = FactoryGirl.create(:user, :admin => true)
      FactoryGirl.create(:chapter)
      FactoryGirl.create(:chapter)

      expect(Chapter.current_chapter_for_user(admin)).to eq(Chapter.first)
    end
    it 'returns first member chapter for a trustee' do
      FactoryGirl.create(:chapter)
      trustee = FactoryGirl.create(:user)
      chapter = FactoryGirl.create(:chapter)
      FactoryGirl.create(:role, :user => trustee, :chapter => chapter)
      expect(Chapter.current_chapter_for_user(trustee)).to eq(chapter)
    end
    it 'returns nil for a user with no chapters' do
      user = FactoryGirl.create(:user)
      expect(user.chapters).to eq([])
      expect(Chapter.current_chapter_for_user(user)).to be_nil
    end
  end

  context '.name' do
    it 'returns the name for an active chapter' do
      chapter = FactoryGirl.build(:chapter, :name => 'Active Chapter')

      expect(chapter.name).to eq('Active Chapter')
    end

    it 'indicates that an inactive chapter is Inactive' do
      chapter = FactoryGirl.build(:inactive_chapter, :name => 'Inactive Chapter')

      expect(chapter.display_name).to eq('Inactive Chapter (Inactive)')
    end
  end
end
