require 'spec_helper'

describe ProjectFilter do
  it 'filters the projects to the specified timeframe' do
    start_date = 3.days.ago.to_fs(:db)
    end_date = 1.days.ago.to_fs(:db)
    matching_project = FactoryBot.create(:project, :created_at => 2.days.ago)
    non_matching_project = FactoryBot.create(:project, :created_at => 6.days.ago)
    project_filter = ProjectFilter.new(Project)

    expect(project_filter.during(start_date, end_date).result).to eq([matching_project])
  end

  it 'paginates the projects' do
    Timecop.freeze(Time.now) do
      first_page_project = FactoryBot.create(:project, :created_at => 1.day.ago)
      second_page_project = FactoryBot.create(:project, :created_at => 30.minutes.ago)
      per_page = 1

      project_filter = ProjectFilter.new(Project)

      expect(project_filter.page(2, per_page).result).to eq([first_page_project])
      expect(project_filter.page(1, per_page).result).to eq([second_page_project])
    end
  end

  it 'can filter the projects to a shortlist' do
    chapter = FactoryBot.create(:chapter)
    shortlisted_project = FactoryBot.create(:project, :chapter => chapter)
    project = FactoryBot.create(:project, :chapter => chapter)
    user = FactoryBot.create(:user_with_dean_role, :chapters => [chapter])
    FactoryBot.create(:vote, :user => user, :project => shortlisted_project, :chapter => chapter)
    FactoryBot.create(:vote, :user => FactoryBot.create(:user, chapters: [chapter]), :project => shortlisted_project, :chapter => chapter)

    project_filter = ProjectFilter.new(Project)
    expect(project_filter.shortlisted_by(user).result).to eq([shortlisted_project])
  end

  it 'can filter the projects to winners only' do
    application = FactoryBot.create(:project)
    winner = FactoryBot.create(:winning_project, chapter: application.chapter)

    project_filter = ProjectFilter.new(Project)
    expect(project_filter.funded.result).to eq([winner])
  end

  describe '#signal_score_above' do
    it 'filters projects at or above the threshold' do
      high = FactoryBot.create(:project)
      high.update_column(:metadata, { "signal_score" => { "composite_score" => 0.8 } })
      low = FactoryBot.create(:project)
      low.update_column(:metadata, { "signal_score" => { "composite_score" => 0.3 } })
      unscored = FactoryBot.create(:project)

      result = ProjectFilter.new(Project).signal_score_above(0.5).result
      expect(result).to include(high)
      expect(result).not_to include(low)
      expect(result).not_to include(unscored)
    end
  end

  describe '#sort_by_signal_score' do
    it 'sorts descending by default (highest first)' do
      low = FactoryBot.create(:project)
      low.update_column(:metadata, { "signal_score" => { "composite_score" => 0.3 } })
      high = FactoryBot.create(:project)
      high.update_column(:metadata, { "signal_score" => { "composite_score" => 0.9 } })
      mid = FactoryBot.create(:project)
      mid.update_column(:metadata, { "signal_score" => { "composite_score" => 0.6 } })

      result = ProjectFilter.new(Project).sort_by_signal_score.result
      expect(result.map(&:id)).to eq([high, mid, low].map(&:id))
    end

    it 'sorts ascending when specified' do
      high = FactoryBot.create(:project)
      high.update_column(:metadata, { "signal_score" => { "composite_score" => 0.9 } })
      low = FactoryBot.create(:project)
      low.update_column(:metadata, { "signal_score" => { "composite_score" => 0.2 } })

      result = ProjectFilter.new(Project).sort_by_signal_score(:asc).result
      expect(result.map(&:id)).to eq([low, high].map(&:id))
    end

    it 'puts unscored projects last in descending order' do
      scored = FactoryBot.create(:project)
      scored.update_column(:metadata, { "signal_score" => { "composite_score" => 0.5 } })
      unscored = FactoryBot.create(:project)

      result = ProjectFilter.new(Project).sort_by_signal_score.result.to_a
      expect(result.first).to eq(scored)
      expect(result.last).to eq(unscored)
    end
  end

  describe '#sort_by_date' do
    it 'sorts by created_at in the given direction' do
      Timecop.freeze(Time.now) do
        old = FactoryBot.create(:project, created_at: 3.days.ago)
        new_proj = FactoryBot.create(:project, created_at: 1.hour.ago)

        asc_result = ProjectFilter.new(Project).sort_by_date(:asc).result
        expect(asc_result.map(&:id)).to eq([old, new_proj].map(&:id))

        desc_result = ProjectFilter.new(Project).sort_by_date(:desc).result
        expect(desc_result.map(&:id)).to eq([new_proj, old].map(&:id))
      end
    end
  end

  describe '#sort_by_random' do
    it 'returns a stable ordering based on project id hash' do
      5.times { FactoryBot.create(:project) }

      first_run = ProjectFilter.new(Project).sort_by_random.result.map(&:id)
      second_run = ProjectFilter.new(Project).sort_by_random.result.map(&:id)

      expect(first_run).to eq(second_run)
    end
  end
end
