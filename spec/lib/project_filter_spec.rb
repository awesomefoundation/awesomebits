require 'spec_helper'

describe ProjectFilter do
  it 'filters the projects to the specified timeframe' do
    start_date = 3.days.ago.to_s(:db)
    end_date = 1.days.ago.to_s(:db)
    matching_project = FactoryGirl.create(:project, :created_at => 2.days.ago)
    non_matching_project = FactoryGirl.create(:project, :created_at => 6.days.ago)
    project_filter = ProjectFilter.new(Project)

    expect(project_filter.during(start_date, end_date).result).to eq([matching_project])
  end

  it 'paginates the projects' do
    Timecop.freeze(Time.now) do
      first_page_project = FactoryGirl.create(:project, :created_at => 1.day.ago)
      second_page_project = FactoryGirl.create(:project, :created_at => 30.minutes.ago)
      per_page = 1

      project_filter = ProjectFilter.new(Project)

      expect(project_filter.page(2, per_page).result).to eq([first_page_project])
      expect(project_filter.page(1, per_page).result).to eq([second_page_project])
    end
  end

  it 'can filter the projects to a shortlist' do
    chapter = FactoryGirl.create(:chapter)
    shortlisted_project = FactoryGirl.create(:project, :chapter => chapter)
    project = FactoryGirl.create(:project, :chapter => chapter)
    user = FactoryGirl.create(:user_with_dean_role, :chapters => [chapter])
    FactoryGirl.create(:vote, :user => user, :project => shortlisted_project)
    FactoryGirl.create(:vote, :user => FactoryGirl.create(:user), :project => shortlisted_project)

    project_filter = ProjectFilter.new(Project)
    expect(project_filter.shortlisted_by(user).result).to eq([shortlisted_project])
  end
end
