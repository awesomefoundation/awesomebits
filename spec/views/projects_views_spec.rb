require 'spec_helper'

describe 'projects/index' do
  let!(:role) { FactoryBot.create(:role, :name => "trustee") }
  let!(:user) { role.user }
  let!(:project) { FactoryBot.create(:project, :extra_question_1 => "Extra Question 1", :extra_answer_1 => "Extra Answer 1", :extra_question_3 => "Unanswered question") }

  it 'displays extra questions and answers' do 
    assign(:chapter, project.chapter)
    assign(:projects, ProjectFilter.new(project.chapter.projects).page(1).result)
    view.stubs(:current_user).returns(user)

    render
    expect(rendered).to have_content("Extra Question 1")
    expect(rendered).to have_content("Extra Answer 1")
    expect(rendered).to have_content("Unanswered question")
    expect(rendered).to have_content(I18n.t("projects.project.not-answered"))
  end
end

describe 'projects/show' do
  let!(:user) { FactoryBot.create(:user) }
  let!(:unfunded_project) { FactoryBot.create(:project) }

  it 'displays the application text for an unfunded project' do 
    assign(:project, unfunded_project)
    view.stubs(:current_user).returns(user)
    
    render
    expect(rendered).to have_content(unfunded_project.about_project)
  end
end

describe 'projects/_form' do
  let(:any_chapter) { Chapter.any_chapter }
  let!(:active_chapter) { FactoryBot.create(:chapter) }
  let!(:inactive_chapter) { FactoryBot.create(:inactive_chapter) }

  before do
    view.stubs(:current_user).returns(Guest.new)
  end

  context 'projects/new' do
    it 'does not show inactive chapters' do
      assign(:project, Project.new)

      render template: 'projects/new'
      expect(rendered).to     have_content(active_chapter.name)
      expect(rendered).not_to have_content(inactive_chapter.name)
    end

    it 'does not show the Any chapter when it is inactive' do
      any_chapter.update!(inactive_at: Time.zone.now)
      assign(:project, Project.new)

      render template: 'projects/new'
      expect(rendered).to have_selector("select#project_chapter_id option[value='#{active_chapter.slug}']", text: active_chapter.name)
      expect(rendered).not_to have_selector("select#project_chapter_id option[value='#{any_chapter.slug}']", text: any_chapter.name)
    end

    it 'shows the Any chapter when it is active' do
      assign(:project, Project.new)

      render template: 'projects/new'
      expect(rendered).to have_selector("select#project_chapter_id option[value='#{any_chapter.slug}']", text: any_chapter.name)
    end

    it 'shows only chapter selection before a chapter is chosen' do
      assign(:project, Project.new)
      render template: 'projects/new'
      expect(rendered).to have_button(I18n.t("projects.form.continue"))
      expect(rendered).not_to have_selector("#project_name")
      expect(rendered).not_to have_selector(".js-uploader")
    end

    it 'renders the intro and nonblank questions in the initial HTML' do
      active_chapter.update!(application_intro: "**Welcome**", extra_question_1: "", extra_question_2: "Why this chapter?", extra_question_3: "What next?")
      assign(:project, Project.new(chapter: active_chapter, extra_question_1: "Why this chapter?", extra_question_2: "What next?"))
      render template: 'projects/new'
      expect(rendered).to have_selector("#application-chapter-intro strong", text: "Welcome")
      expect(rendered).to have_selector('label[for="project_extra_answer_1"]', text: "Why this chapter?")
      expect(rendered).to have_selector('label[for="project_extra_answer_2"]', text: "What next?")
      expect(rendered).not_to have_selector("#project_extra_answer_3")
      expect(rendered).not_to include("var extra_questions")
      expect(rendered).to have_selector('input[name="project[extra_question_1]"][value="Why this chapter?"]', visible: false)
    end

    it 'renders hidden chapter and empty question fields for chapters without questions' do
      assign(:project, Project.new(chapter: active_chapter))
      render template: 'projects/new'
      expect(rendered).to have_selector("#application-chapter-questions input[name='chapter'][value='#{active_chapter.slug}']", visible: false)
      expect(rendered).not_to have_selector('[name="project[chapter_id]"]', visible: false)
      expect(rendered).not_to have_selector(".extra-answer")
    end

  end

  context 'projects/edit' do
    it 'includes the Any chapter even when it is inactive' do
      any_chapter.update!(inactive_at: Time.current)
      assign(:project, FactoryBot.create(:project, chapter: active_chapter))

      render template: 'projects/edit'

      expect(rendered).to have_selector("select[name='chapter'] option[value='#{any_chapter.slug}']", text: any_chapter.name)
    end

    it 'renders saved question fields without renumbering gaps or clearing unrendered answers' do
      project = FactoryBot.create(:project, chapter: active_chapter, extra_answer_1: "Answer without question", extra_question_3: "Saved third question?", extra_answer_3: "Saved third answer")
      assign(:project, project)

      render template: 'projects/edit'

      expect(rendered).to have_selector('label[for="project_extra_answer_3"]', text: "Saved third question?")
      expect(rendered).to have_selector('input[name="project[extra_question_3]"][value="Saved third question?"]', visible: false)
      expect(rendered).not_to have_selector('[name="project[extra_answer_1]"]', visible: false)
      expect(rendered).not_to have_selector('[name="project[extra_question_1]"]', visible: false)
    end

    it 'shows inactive chapters' do
      assign(:project, FactoryBot.create(:project, :chapter => inactive_chapter))

      render :template => 'projects/edit'
      expect(rendered).to have_content(active_chapter.name)
      expect(rendered).to have_content(inactive_chapter.name)
      expect(rendered).to have_selector("select[name='chapter'] option[selected][value='#{inactive_chapter.slug}']")
      expect(rendered).not_to have_selector('[name="project[chapter_id]"]', visible: false)
    end
  end
end
