require 'spec_helper'

describe Project do
  it { is_expected.to belong_to :chapter }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :about_me }
  it { is_expected.to validate_presence_of :about_project }
  it { is_expected.to validate_presence_of :use_for_money }
  it { is_expected.to validate_presence_of :chapter_id }
  it { is_expected.to have_many(:votes) }
  it { is_expected.to have_many(:users).through(:votes) }
  it { is_expected.to have_many(:photos) }

  context '#save' do
    let(:fake_mailer) { FakeMailer.new }
    let(:project) { FactoryGirl.build(:project) }

    it 'sends an email to the applicant on successful save' do
      project.mailer = fake_mailer
      project.save
      expect(fake_mailer).to have_delivered_email(:new_application)
    end
  end

  context '#chapter_name' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let(:project) { FactoryGirl.create :project, :chapter => chapter }
    it 'should delegate to chapter' do
      expect(project.chapter_name).to eq('Test chapter')
    end
  end

  context '.winner_count' do
    let!(:winners) { (1..2).map{|x| FactoryGirl.create(:project, :funded_on => Date.today) } }
    let!(:non_winners){ (1..3).map{|x| FactoryGirl.create(:project, :funded_on => nil) } }
    it 'counts the winners' do
      expect(Project.winner_count).to eq(2)
    end
  end

  context '.visible_to' do
    let(:role){ FactoryGirl.create(:role) }
    let(:user){ role.user }
    let(:chapter){ role.chapter }
    let(:any_chapter){ Chapter.find_by_name("Any") }
    let!(:good_project){ FactoryGirl.create(:project, :chapter => chapter) }
    let!(:bad_project){ FactoryGirl.create(:project) }
    let!(:any_project){ FactoryGirl.create(:project, :chapter => any_chapter) }

    it 'finds the projects a user has access to' do
      projects = Project.visible_to(user)
      expect(projects).to include(good_project)
      expect(projects).to include(any_project)
      expect(projects).not_to include(bad_project)
    end
  end

  context '.during_timeframe' do
    let(:start_date) { "2001-01-01" }
    let(:end_date) { "2010-10-10" }
    let!(:before_start) { FactoryGirl.create(:project, :created_at => Date.parse("2000-12-31")) }
    let!(:before_end) { FactoryGirl.create(:project, :created_at => Date.parse("2001-01-02")) }
    let!(:after_start) { FactoryGirl.create(:project, :created_at => Date.parse("2010-10-09")) }
    let!(:after_end) { FactoryGirl.create(:project, :created_at => Date.parse("2010-10-11")) }

    it 'searches between two dates' do
      actual = Project.during_timeframe(start_date, end_date)
      expect(actual).not_to include(after_end)
      expect(actual).not_to include(before_start)
      expect(actual).to include(after_start)
      expect(actual).to include(before_end)
    end

    it 'defaults to all dates if none are supplied' do
      actual = Project.during_timeframe(nil, nil)
      expect(actual).to include(after_end)
      expect(actual).to include(before_start)
      expect(actual).to include(after_start)
      expect(actual).to include(before_end)
    end
  end

  context '#shortlisted_by?' do
    let!(:vote){ FactoryGirl.create(:vote) }
    let!(:user){ vote.user }
    let!(:project){ vote.project }
    let!(:other_user) { FactoryGirl.create(:user) }

    it 'returns true if this project had been shortlisted by the given user' do
      expect(project.shortlisted_by?(user)).to be_truthy
    end

    it 'returns false if this project had not been shortlisted by the given user' do
      expect(project.shortlisted_by?(other_user)).not_to be_truthy
    end
  end

  context '.voted_for_by_members_of' do
    let(:boston){ FactoryGirl.create(:chapter) }
    let(:boston_project) { FactoryGirl.create(:project, :chapter => boston) }
    let(:boston_trustee) { FactoryGirl.create(:user) }
    let!(:boston_role) { FactoryGirl.create(:role, :user => boston_trustee, :chapter => boston) }
    let!(:boston_vote) do
      FactoryGirl.create(:vote, :project => boston_project, :user => boston_trustee)
    end
    let(:chicago){ FactoryGirl.create(:chapter) }
    let(:chicago_project) { FactoryGirl.create(:project, :chapter => chicago) }
    let(:chicago_trustee) { FactoryGirl.create(:user) }
    let!(:chicago_role) { FactoryGirl.create(:role, :user => chicago_trustee, :chapter => chicago) }
    let!(:chicago_vote) do
      FactoryGirl.create(:vote, :project => chicago_project, :user => chicago_trustee)
    end

    it 'returns the projects that the given chapter has voted on' do
      expect(Project.voted_for_by_members_of(boston)).to eq([boston_project])
      expect(Project.voted_for_by_members_of(chicago)).to eq([chicago_project])
    end
  end

  context '.by_vote_count' do
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:projects) { [FactoryGirl.create(:project, :chapter => chapter),
                      FactoryGirl.create(:project, :chapter => chapter),
                      FactoryGirl.create(:project, :chapter => chapter)] }
    before do
      2.times{ FactoryGirl.create(:vote, :project => projects[1]) }
      1.times{ FactoryGirl.create(:vote, :project => projects[2]) }
      0.times{ FactoryGirl.create(:vote, :project => projects[0]) }
    end

    it 'returns the projects in descending order of vote_count' do
      expect(Project.by_vote_count.map(&:id)).to eq([projects[1].id, projects[2].id])
    end

    it 'gives each returned project a #vote_count getter with its count' do
      expect(Project.by_vote_count[0].vote_count).to eq(2)
      expect(Project.by_vote_count[1].vote_count).to eq(1)
    end
  end

  context '.recent_winners' do
    let!(:loser) { FactoryGirl.create(:project) }
    let!(:old_winner) { FactoryGirl.create(:project, :funded_on => 2.days.ago) }
    let!(:new_winner) { FactoryGirl.create(:project, :funded_on => 1.days.ago) }
    let!(:ignored_winner) { FactoryGirl.create(:project, :funded_on => 1.week.ago, :chapter_id => new_winner.chapter_id) }
    it 'returns one project per chapter  by descending funding date' do
      expect(Project.recent_winners).to eq([new_winner, old_winner])
    end
  end

  context "#declare_winner!" do
    let(:project) { FactoryGirl.create(:project) }
    let(:chapter) { project.chapter }
    let(:other_chapter) { FactoryGirl.create(:chapter) }

    it 'sets the #funded_on attribute' do
      project.declare_winner!
      expect(project.funded_on).to eq(Date.today)
    end

    it 'does not move the project to a different chapter, if not supplied' do
      project.declare_winner!
      expect(project.chapter).to eq(chapter)
    end

    it 'moves the project to a different chapter, if supplied' do
      project.declare_winner!(other_chapter)
      expect(project.chapter).to eq(other_chapter)
    end

    it 'populates the funded description' do
      project.declare_winner!
      expect(project.funded_description).to eq(project.about_project)
    end

    it 'does not replace an existing funded description' do
      project.funded_description = 'I am funded'
      project.declare_winner!
      expect(project.funded_description).to eq('I am funded')
    end

    it 'saves the record' do
      project.declare_winner!
      expect(Project.find(project.id).funded_on).to eq(Date.today)
    end
  end

  context "#revoke_winner!" do
    let(:project) { FactoryGirl.create(:project) }
    before{ project.declare_winner! }

    it 'sets the #funded_on attribute' do
      project.revoke_winner!
      expect(project.funded_on).to be_nil
    end

    it 'saves the record' do
      project.revoke_winner!
      expect(Project.find(project.id).funded_on).to be_nil
    end
  end

  context "#in_any_chapter?" do
    let(:project){ FactoryGirl.build(:project, :chapter => Chapter.where(:name == "Any").first) }
    let(:other_project) { FactoryGirl.build(:project) }

    it 'is true when the project is in the Any chapter' do
      expect(project.in_any_chapter?).to be_truthy
    end

    it 'is false when the project is in some other chapter' do
      expect(other_project.in_any_chapter?).to be_falsey
    end
  end

  context '#new_photos=' do
    let(:project) { FactoryGirl.build(:project) }

    it 'creates new Photo records' do
      project.new_photos = [FakeData.fixture_file("1.JPG")]
      expect(project.photos.first.image.original_filename).to eq("1.JPG")
    end

    it 'creates and saves new Photo records if the Project has been saved' do
      project.new_photos = [FakeData.fixture_file("1.JPG")]
      expect(project.photos.first.image.original_filename).to eq("1.JPG")
      project.save
      expect(project.photos.first.new_record?).to be_falsey

      project.new_photos = [FakeData.fixture_file("2.JPG")]
      expect(project.photos.last.image.original_filename).to eq("2.JPG")
    end
  end

  context '#photo_order' do
    let(:project) { FactoryGirl.create(:project) }
    let(:photo1)  { FactoryGirl.create(:photo, :project => project) }
    let(:photo2)  { FactoryGirl.create(:photo, :project => project) }
    let(:photo3)  { FactoryGirl.create(:photo, :project => project) }

    it "returns a string of the photos' ids in order" do
      project.photos = [photo1, photo2, photo3]
      expected = [photo1, photo2, photo3].map(&:id).join(" ")
      expect(project.photo_order).to eq(expected)
    end
  end

  context '#photo_order=' do
    before do
      @project = FactoryGirl.create(:project)
      @photo1  = FactoryGirl.create(:photo, :project => @project)
      @photo2  = FactoryGirl.create(:photo, :project => @project)
      @photo3  = FactoryGirl.create(:photo, :project => @project)
    end

    it 'sets the order of the photos based on their position in the string' do
      @project.photo_order = [@photo2.id, @photo3.id, @photo1.id].join(" ")
      @project.save

      expect(@project.reload.photos).to eq([@photo2, @photo3, @photo1])
    end

    it 'does not remove photos if they are not in the string' do
      @project.photo_order = [@photo2.id, @photo1.id].join(" ")
      @project.save

      expect(@project.reload.photos).to eq([@photo2, @photo1, @photo3])
      #expect { Photo.find(@photo3.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  context "#photo_ids_to_delete=" do
    before do
      @project = FactoryGirl.create(:project)
      @photo1  = FactoryGirl.create(:photo, :project => @project)
      @photo2  = FactoryGirl.create(:photo, :project => @project)
    end

    it 'removes photos if they are in the array' do
      @project.photo_ids_to_delete = [@photo1.id]
      @project.save

      expect(@project.reload.photos).to eq([@photo2])
    end
  end

  context '#display_images' do
    let(:project) { FactoryGirl.build_stubbed(:project) }
    it "returns the photos if there are any" do
      photo = FactoryGirl.create(:photo)
      project.photos = [photo]
      expect(project.display_images.map(&:url)).to eq([photo.url])
    end

    it "returns a new photo if there aren't any" do
      expect(project.display_images.map(&:url)).to eq([Photo.new.url])
    end

    it "returns a new photo if the only photo is a non-image" do
      project.photos = [FactoryGirl.create(:pdf)]
      expect(project.display_images.map(&:url)).to eq([Photo.new.url])
    end

    it "only returns image files for display" do
      pdf = FactoryGirl.create(:pdf)
      image = FactoryGirl.create(:photo)
      project.photos = [pdf, image]
      expect(project.display_images).to eq([image])
    end
  end

  context 'pagination' do
    it 'has 30 items per page' do
      expect(Chapter.per_page).to eq(30)
    end
  end

  context "url validation" do
    let(:project) { FactoryGirl.build(:project) }

    it 'leaves the url alone if it has a scheme' do
      project.url = "https://example.com"
      project.valid?

      expect(project.url).to eq("https://example.com")
    end

    it 'leaves the rss feed url alone if it has a scheme' do
      project.rss_feed_url = "https://example.com/rss"
      project.valid?

      expect(project.rss_feed_url).to eq("https://example.com/rss")
    end

    it 'adds a url scheme if it does not have one' do
      project.url = "example.com"
      project.valid?

      expect(project.url).to eq("http://example.com")
    end

    it 'adds a rss feed url scheme if it does not have one' do
      project.rss_feed_url = "example.com/rss"
      project.valid?

      expect(project.rss_feed_url).to eq("http://example.com/rss")
    end

    it 'leaves the url bank if it is blank' do
      project.url = ''
      project.valid?

      expect(project.url).to eq('')
    end

    it 'rejects an invalid url' do
      project.url = "url with spaces"
      expect(project).to_not be_valid
    end

    it 'rejects an invalid rss url' do
      project.rss_feed_url = "url with spaces"
      expect(project).to_not be_valid
    end

    it 'rejects a url that is too long before url normalization' do
      project.url = "a" * 255
      expect(project).to_not be_valid
    end
  end

  describe "#hide! / #hidden?" do
    let(:project) { FactoryGirl.create(:project) }
    let(:user) { FactoryGirl.create(:user) }
    let(:reason) { Faker::Company.bs }

    it "saves the reason" do
      project.hide!(reason, user)
      expect(project.reload.hidden_reason).to eq(reason)
    end

    it "saves the user id" do
      project.hide!(reason, user)
      expect(project.reload.hidden_by_user).to eq(user)
    end

    it "makes it hidden" do
      expect(project).not_to be_hidden
      project.hide!(reason, user)
      expect(project).to be_hidden
    end

    it "saves the time" do
      Timecop.freeze(Time.now) do
        project.hide!(reason, user)
        expect(project.hidden_at).to eq(Time.zone.now)
      end
    end
  end

  describe "#unhide! / #hidden?" do
    let(:project) {
      FactoryGirl.create(:project, {
        hidden_reason: Faker::Company.bs,
        hidden_by_user_id: 123,
        hidden_at: Time.now
      })
    }

    it "unhides it" do
      expect(project).to be_hidden
      project.unhide!
      expect(project).not_to be_hidden
    end
  end
end

describe Project, 'csv_export' do
  let!(:project) do
    FactoryGirl.create :project,
    :name => 'Name',
    :url => 'http://example.com',
    :email => 'mail@example.com',
    :phone => '555-555-5555',
    :about_me => 'About me',
    :about_project => 'About project',
    :title => 'Title',
    :funded_on => Date.new(2012,1,1),
    :rss_feed_url => 'http://example.com/rss',
    :use_for_money => 'Fun',
    :hidden_at => Time.new(2012, 1, 2).utc,
    :hidden_reason => 'not awesome'
  end
  subject { Project.csv_export([project]) }
  let(:parsed)  { CSV.parse(subject).to_a }

  it 'adds headers' do
    expect(parsed.first).to eq(%w(name title about_project use_for_money about_me url email phone chapter_name id created_at funded_on extra_question_1 extra_answer_1 extra_question_2 extra_answer_2 extra_question_3 extra_answer_3 rss_feed_url hidden_at hidden_reason))
  end

  it 'includes basic information for a project' do
    expect(parsed).to include(['Name', 'Title', 'About project', 'Fun', 'About me', 'http://example.com','mail@example.com','555-555-5555', project.chapter.name.to_s, project.id.to_s, project.created_at.to_s, '2012-01-01', '', '', '', '', '', '', 'http://example.com/rss', Time.new(2012, 1, 2).utc.to_s, 'not awesome'])
  end
end
