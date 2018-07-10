require 'spec_helper'

describe ProjectNavHelper do

  context 'next_link' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:project) { FactoryGirl.create :project, :chapter => chapter }

    it 'Единственный проект не может иметь ссылки на следующий' do
      expect(helper.next_project_id project).to be_nil
    end

    it 'Первый проект имеет сслыку next_project на 2й проект' do
      second_project = FactoryGirl.create :project, :chapter => chapter
      expect(helper.next_project_id project).to eq(second_project.id)
    end

    it 'Последний проект не может иметь следующего' do
      second_project = FactoryGirl.create :project, :chapter => chapter
      expect(helper.next_project_id second_project).to be_nil
    end
  end

  context 'prev_link' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:project) { FactoryGirl.create :project, :chapter => chapter }

    it 'Единственный проект не может иметь ссылки на предыдущий' do
      expect(helper.prev_project_id project).to be_nil
    end

    it 'Второй проект имеет сслыку prev_project на 1й проект' do
      second_project = FactoryGirl.create :project, :chapter => chapter
      expect(helper.prev_project_id second_project).to eq(project.id)
    end

    it 'Первый проект не может иметь prev_project ссылки' do
      second_project = FactoryGirl.create :project, :chapter => chapter
      expect(helper.prev_project_id project).to be_nil
    end
  end

  context 'private methods' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:first_project) { FactoryGirl.create :project, :chapter => chapter }
    let!(:last_project) { FactoryGirl.create :project, :chapter => chapter }

    context 'is_first_project' do
      it 'Первый проект является первым' do
        expect(helper.send(:is_first_project?, first_project)).to be true
      end

      it 'Последний проект не является первым' do
        expect(helper.send(:is_first_project?, last_project)).to be false
      end
    end

    context 'is_last_project' do
      it 'Последний проект является последним' do
        expect(helper.send(:is_last_project?, last_project)).to be true
      end

      it 'Последний проект не является первым' do
        expect(helper.send(:is_last_project?, first_project)).to be false
      end
    end
  end
end