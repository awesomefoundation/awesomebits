require 'spec_helper'
require 'date'

describe ProjectNavHelper do
  describe '#project_winning_siblings' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:project) { FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today + 1 }

    it 'returns no siblings for single project' do
      expect(helper.project_winning_siblings(project).compact).to be_empty
    end

    it 'returns no siblings for not winning project' do
      not_winning_project = FactoryGirl.create :project, :chapter => chapter
      expect(helper.project_winning_siblings(not_winning_project).compact).to be_empty
    end

    it 'does not include not winning projects as siblings' do
      not_winning_projects = FactoryGirl.create_list :project, 2, :chapter => chapter
      expect(helper.project_winning_siblings(project).compact).to be_empty
    end

    it 'returns Next sibling for first project' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.project_winning_siblings(project).last).to eq(second_project)
    end

    it 'returns Prev sibling for second project' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.project_winning_siblings(second_project).first).to eq(project)
    end

    it 'returns no Next sibling for last project' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.project_winning_siblings(second_project).last).to be_nil
    end

    it 'returns no Prev sibling for first project' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.project_winning_siblings(project).first).to be_nil
    end

    it 'returns Prev, Next siblings' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      third_project  = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today - 1
      expect(helper.project_winning_siblings(second_project)).to eq([project, third_project])
    end
  end
end
