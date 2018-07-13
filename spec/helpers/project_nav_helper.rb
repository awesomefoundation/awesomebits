require 'spec_helper'
require 'date'

describe ProjectNavHelper do

  context 'next_link' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:project) { FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today + 1 }

    # Единственный проект не может иметь ссылки на следующий
    it 'A single project can not have a reference to the following' do
      expect(helper.next_project_id project).to be_nil
    end

    # Первый проект имеет сслыку next_project на 2й проект
    it 'The first project has a link next_project for the 2nd project' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.next_project_id project).to eq(second_project.id)
    end

    # Последний проект не может иметь следующего
    it 'The last project can not have the following' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.next_project_id second_project).to be_nil
    end
  end

  context 'prev_link' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:project) { FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today + 1 }

    # Единственный проект не может иметь ссылки на предыдущий
    it 'A single project can not have a link to the previous one' do
      expect(helper.prev_project_id project).to be_nil
    end

    # Второй проект имеет сслыку prev_project на 1й проект
    it 'The second project has a link prev_project for the 1st project' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.prev_project_id second_project).to eq(project.id)
    end

    # Первый проект не может иметь prev_project ссылки
    it 'The first project can not have prev_project links' do
      second_project = FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today
      expect(helper.prev_project_id project).to be_nil
    end
  end

  context 'private methods' do
    let(:chapter) { FactoryGirl.create :chapter, :name => 'Test chapter' }
    let!(:first_project) { FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today + 1 }
    let!(:last_project) { FactoryGirl.create :project, :chapter => chapter, :funded_on => Date.today }

    context 'is_first_project?' do

      # Первый проект является первым
      it 'The first project is the first' do
        expect(helper.send(:is_first_project?, first_project)).to be_truthy
      end

      # Последний проект не является первым
      it 'The last project is not the first one' do
        expect(helper.send(:is_first_project?, last_project)).to be_falsey
      end
    end

    context 'is_last_project?' do

      # Последний проект является последним
      it 'The last project is the last one' do
        expect(helper.send(:is_last_project?, last_project)).to be_truthy
      end

      # Последний проект не является первым
      it 'The last project is not the first one' do
        expect(helper.send(:is_last_project?, first_project)).to be_falsey
      end
    end

    context 'chapter_projects_keys' do

      # Правильная сортировка ключей в методе chapter_projects_keys
      it 'The correct sorting of keys in the chapter_projects_keys method' do
        expect(helper.send(:chapter_projects_keys, first_project)).to eq([first_project.id, last_project.id])
      end
    end
  end
end
