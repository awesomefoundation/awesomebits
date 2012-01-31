require 'spec_helper'

describe Project do
  it { should belong_to :chapter }
  it { should validate_presence_of :name }
  it { should validate_presence_of :title }
  it { should validate_presence_of :email }
  it { should validate_presence_of :use }
  it { should validate_presence_of :chapter_id }
  it { should validate_presence_of :description }

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
    let(:any_chapter){ FactoryGirl.create(:chapter, :name => "Any") }
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
end
