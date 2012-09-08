require 'spec_helper'

describe 'projects/index' do
  let!(:role) { create(:role, :name => "trustee") }
  let!(:user) { role.user }
  let!(:project) { create(:project, :extra_question_1 => "Extra Question 1", :extra_answer_1 => "Extra Answer 1") }

  it 'displays extra questions and answers' do 
    assign(:chapter, project.chapter)
    assign(:projects, ProjectFilter.new(project.chapter.projects).page(1).result)
    view.stubs(:current_user).returns(user)

    render
    rendered.should have_content("Extra Question 1")
    rendered.should have_content("Extra Answer 1")
  end
end
