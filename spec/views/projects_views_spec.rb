require 'spec_helper'

describe 'projects/index' do
  let!(:role) { FactoryGirl.create(:role, :name => "trustee") }
  let!(:user) { role.user }
  let!(:project) { FactoryGirl.create(:project, :extra_question_1 => "Extra Question 1", :extra_answer_1 => "Extra Answer 1") }

  it 'displays extra questions and answers' do 
    assign(:chapter, project.chapter)
    assign(:projects, ProjectFilter.new(project.chapter.projects).page(1).result)
    view.stubs(:current_user).returns(user)

    render
    rendered.should have_content("Extra Question 1")
    rendered.should have_content("Extra Answer 1")
  end
end

describe 'projects/show' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:unfunded_project) { FactoryGirl.create(:project) }

  it 'displays the application text for an unfunded project' do 
    assign(:project, unfunded_project)
    view.stubs(:current_user).returns(user)
    
    render
    rendered.should have_content(unfunded_project.about_project)
  end
end

describe 'projects/public_show' do
  let!(:funded_project) { FactoryGirl.create(:project, :funded_on => Time.zone.now.to_date, :funded_description => "I am a funded project") }
    
  it 'displays the funded description for a funded project' do 
    assign(:project, funded_project)
    view.stubs(:current_user).returns(Guest.new)

    render
    rendered.should have_content(funded_project.funded_description)
  end
end

describe 'projects/_form' do
  let!(:active_chapter) { FactoryGirl.create(:chapter) }
  let!(:inactive_chapter) { FactoryGirl.create(:inactive_chapter) }

  before do
    view.stubs(:current_user).returns(Guest.new)
  end

  context 'projects/new' do
    it 'does not show inactive chapters' do
      assign(:project, Project.new)

      render :template => 'projects/new'
      rendered.should     have_content(active_chapter.name)
      rendered.should_not have_content(inactive_chapter.name)
    end
  end

  context 'projects/edit' do
    it 'shows inactive chapters' do
      assign(:project, FactoryGirl.create(:project, :chapter => inactive_chapter))

      render :template => 'projects/edit'
      rendered.should have_content(active_chapter.name)
      rendered.should have_content(inactive_chapter.name)
    end
  end
end
