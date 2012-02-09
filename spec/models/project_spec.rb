require 'spec_helper'

describe Project do
  it { should belong_to :chapter }
  it { should validate_presence_of :name }
  it { should validate_presence_of :title }
  it { should validate_presence_of :email }
  it { should validate_presence_of :use }
  it { should validate_presence_of :chapter_id }
  it { should validate_presence_of :description }
  it { should have_many(:votes) }
  it { should have_many(:users).through(:votes) }

  context '#save' do
    let(:fake_mailer) { FakeMailer.new }
    let(:project) { FactoryGirl.build(:project) }

    it 'sends an email to the applicant on successful save' do
      project.mailer = fake_mailer
      project.save
      fake_mailer.should have_delivered_email(:new_application)
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
      projects = Project.visible_to(user).all
      projects.should include(good_project)
      projects.should include(any_project)
      projects.should_not include(bad_project)
    end
  end

  context '.during_timeframe' do
    let(:start_date) { Date.parse("2001-01-01") }
    let(:end_date) { Date.parse("2010-10-10") }
    let!(:before_start) { FactoryGirl.create(:project, :created_at => Date.parse("2000-12-31")) }
    let!(:before_end) { FactoryGirl.create(:project, :created_at => Date.parse("2001-01-02")) }
    let!(:after_start) { FactoryGirl.create(:project, :created_at => Date.parse("2010-10-09")) }
    let!(:after_end) { FactoryGirl.create(:project, :created_at => Date.parse("2010-10-11")) }

    it 'searches between two dates' do
      actual = Project.during_timeframe(start_date, end_date)
      actual.should_not include(after_end)
      actual.should_not include(before_start)
      actual.should include(after_start)
      actual.should include(before_end)
    end

    it 'defaults to all dates if none are supplied' do
      actual = Project.during_timeframe(nil, nil)
      actual.should include(after_end)
      actual.should include(before_start)
      actual.should include(after_start)
      actual.should include(before_end)
    end
  end

  context '#shortlisted_by?' do
    let!(:vote){ FactoryGirl.create(:vote) }
    let!(:user){ vote.user }
    let!(:project){ vote.project }
    let!(:other_user) { FactoryGirl.create(:user) }

    it 'returns true if this project had been shortlisted by the given user' do
      project.shortlisted_by?(user).should be_true
    end

    it 'returns false if this project had not been shortlisted by the given user' do
      project.shortlisted_by?(other_user).should_not be_true
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
      Project.voted_for_by_members_of(boston).should == [boston_project]
      Project.voted_for_by_members_of(chicago).should == [chicago_project]
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
      Project.by_vote_count.map(&:id).should == [projects[1].id, projects[2].id]
    end

    it 'gives each returned project a #vote_count getter with its count' do
      Project.by_vote_count[0].vote_count.should == "2"
      Project.by_vote_count[1].vote_count.should == "1"
    end
  end

  context "#declare_winner!" do
    let(:project) { FactoryGirl.create(:project) }

    it 'sets the #funded_on attribute' do
      project.declare_winner!
      project.funded_on.should == Date.today
    end

    it 'saves the record' do
      project.declare_winner!
      Project.find(project.id).funded_on.should == Date.today
    end
  end

end
