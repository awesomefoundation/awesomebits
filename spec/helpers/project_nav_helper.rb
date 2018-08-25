require 'spec_helper'
require 'date'

describe ProjectNavHelper do
  describe '#project_winning_siblings' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:project) { FactoryGirl.create :winning_project, :chapter => chapter }

    context 'for a single winning project' do
      it 'returns no siblings' do
        expect(helper.project_winning_siblings(project).compact).to be_empty
      end

      it 'does not include not winning projects as siblings' do
        not_winning_projects = FactoryGirl.create_list :project, 2, :chapter => chapter
        expect(helper.project_winning_siblings(project).compact).to be_empty
      end
    end

    context 'for a single not winning project' do
      it 'returns no siblings' do
        not_winning_project = FactoryGirl.create :project, :chapter => chapter
        expect(helper.project_winning_siblings(not_winning_project).compact).to be_empty
      end
    end

    context 'with winning projects' do
      let!(:next_project)     { FactoryGirl.create :project, :chapter => chapter, :funded_on => project.funded_on - 1.day }
      let!(:previous_project) { FactoryGirl.create :project, :chapter => chapter, :funded_on => project.funded_on + 1.day }

      it 'returns Next sibling for first project' do
        expect(helper.project_winning_siblings(previous_project).last).to eq(project)
      end

      it 'returns no Prev sibling for first project' do
        expect(helper.project_winning_siblings(previous_project).first).to be_nil
      end

      it 'returns Prev sibling for last project' do
        expect(helper.project_winning_siblings(next_project).first).to eq(project)
      end

      it 'returns no Next sibling for last project' do
        expect(helper.project_winning_siblings(next_project).last).to be_nil
      end

      it 'returns Prev, Next siblings' do
        expect(helper.project_winning_siblings(project)).to eq([previous_project, next_project])
      end
    end
  end
end
