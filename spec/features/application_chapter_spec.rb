require "spec_helper"

describe "Application chapter selection", type: :feature do
  let!(:first_chapter) { FactoryBot.create(:chapter, extra_question_1: "First chapter question?") }
  let!(:second_chapter) { FactoryBot.create(:chapter, extra_question_1: "Second chapter question?", application_intro: "Second chapter intro") }

  it "opens a complete application after chapter selection without JavaScript" do
    visit new_submission_path
    expect(page).not_to have_field("project_name")
    select first_chapter.name, from: "Select chapter to apply to"
    click_button I18n.t("projects.form.continue")
    expect(page).to have_field("First chapter question?")
    expect(URI.decode_www_form(URI(page.current_url).query).to_h).to include("chapter" => first_chapter.slug)
    fill_in "project_name", with: "Applicant"
    fill_in "project_title", with: "Project"
    fill_in "project_email", with: "applicant@example.com"
    fill_in "project_about_me", with: "About me"
    fill_in "project_about_project", with: "About project"
    fill_in "project_use_for_money", with: "Materials"
    click_button "Apply"
    expect(page).to have_content(I18n.t("projects.success.title"))
    expect(Project.last.extra_question_1).to eq("First chapter question?")
  end

  it "keeps an empty saved question set when a trustee changes chapters without JavaScript" do
    project = FactoryBot.create(:project, chapter: first_chapter)
    user = FactoryBot.create(:user, admin: true, password: "12345")
    visit sign_in_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "12345"
    click_button "Sign in"
    visit edit_project_path(project)
    expect(page).not_to have_field("First chapter question?")
    select second_chapter.name, from: "project_chapter_id"
    expect(page).not_to have_field("Second chapter question?")
    click_button "Save"
    expect(page).to have_current_path(chapter_project_path(second_chapter, project), ignore_query: true)
    expect(project.reload.chapter).to eq(second_chapter)
    expect(project.extra_question_1).to be_nil
    expect(project.extra_answer_1).to be_nil
  end

  context "with JavaScript", js: true do
    before do
      visit new_submission_path(chapter: first_chapter.slug)
      expect(page).to have_select("project_chapter_id", disabled: false)
    end

    it "automatically opens the application when a chapter is selected" do
      visit new_submission_path
      select first_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("project_name")
      expect(page).to have_field("First chapter question?")
    end

    it "retains the draft when its chapter becomes inactive and another chapter is selected" do
      fill_in "project_name", with: "Keep my name"
      fill_in "project_title", with: "Keep my project"
      fill_in "project_email", with: "applicant@example.com"
      fill_in "project_about_me", with: "About me"
      fill_in "project_about_project", with: "About project"
      fill_in "project_use_for_money", with: "Materials"
      first_chapter.update!(inactive_at: Time.current)
      click_button "Apply"

      expect(page).to have_content(/#{Regexp.escape(I18n.t("flash.applications.error"))}/i)
      expect(Project.count).to eq(0)
      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("Second chapter question?")
      expect(page).to have_field("project_name", with: "Keep my name")
      expect(page).to have_field("project_title", with: "Keep my project")
      click_button "Apply"

      expect(page).to have_current_path(success_submissions_path(chapter: second_chapter))
      expect(Project.last.chapter).to eq(second_chapter)
    end

    it "preserves general fields and the uploader while clearing chapter answers" do
      fill_in "project_name", with: "Keep my name"
      fill_in "First chapter question?", with: "Old answer"
      page.execute_script("document.querySelector('.js-uploader').dataset.preservationCheck = 'original'")
      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("Second chapter question?", with: "")
      expect(page).to have_current_path(new_submission_path(chapter: second_chapter.slug))
      expect(page).to have_content("Second chapter intro")
      expect(page).to have_field("project_name", with: "Keep my name")
      expect(page).to have_css('.js-uploader[data-preservation-check="original"]')
      select first_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("First chapter question?", with: "")
      expect(page).to have_current_path(new_submission_path(chapter: first_chapter.slug))
    end

    it "restores the previous chapter and answers after a failed request" do
      fill_in "First chapter question?", with: "Keep this answer"
      page.execute_script(<<~JS)
        document.getElementById("chapter-picker").addEventListener("turbo:before-fetch-request", event => {
          event.detail.fetchRequest = { response: Promise.reject(new TypeError("Network failed")) }
        }, { once: true })
      JS
      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_content(I18n.t("projects.form.chapter-load-error"))
      expect(page).to have_select("project_chapter_id", selected: first_chapter.name, disabled: false)
      expect(page).to have_field("First chapter question?", with: "Keep this answer")
      expect(page).to have_current_path(new_submission_path(chapter: first_chapter.slug))
      expect(page).to have_button("Apply", disabled: false)
    end

    it "locks chapter selection until the response body has replaced the questions" do
      page.execute_script(<<~JS)
        document.getElementById("chapter-picker").addEventListener("turbo:before-fetch-response", event => {
          const response = event.detail.fetchResponse
          const html = response.responseHTML
          Object.defineProperty(response, "responseHTML", { get() {
            return new Promise(resolve => {
              window.releaseChapterBody = () => html.then(resolve)
            })
          } })
        }, { once: true })
      JS
      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_select("project_chapter_id", disabled: true)
      expect(page).to have_css('#chapter-picker:not([aria-busy])')
      expect(page).to have_button("Apply", disabled: true)
      expect(page).to have_field("First chapter question?")

      page.execute_script("window.releaseChapterBody()")
      expect(page).to have_field("Second chapter question?")
      expect(page).to have_select("project_chapter_id", disabled: false)
      expect(page).to have_button("Apply", disabled: false)
      expect(page).to have_current_path(new_submission_path(chapter: second_chapter.slug))

      select first_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("First chapter question?")
      expect(page).to have_select("project_chapter_id", disabled: false)
    end

    it "unlocks chapter selection when downloading the response body fails" do
      page.execute_script(<<~JS)
        document.getElementById("chapter-picker").addEventListener("turbo:before-fetch-request", event => {
          const response = new Response("", { headers: { "Content-Type": "text/vnd.turbo-stream.html" } })
          response.clone = () => ({ text: () => Promise.reject(new TypeError("Body download failed")) })
          event.detail.fetchRequest = { response: Promise.resolve(response) }
        }, { once: true })
      JS
      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_content(I18n.t("projects.form.chapter-load-error"))
      expect(page).to have_select("project_chapter_id", selected: first_chapter.name, disabled: false)
      expect(page).to have_button("Apply", disabled: false)
      expect(page).to have_field("First chapter question?")

      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("Second chapter question?")
      expect(page).to have_select("project_chapter_id", disabled: false)
    end

    it "keeps the application in place when the chapter response fails" do
      page.execute_script("document.getElementById('chapter-picker').action = '/404'")
      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_content(I18n.t("projects.form.chapter-load-error"))
      expect(page).to have_field("First chapter question?")
      expect(page).to have_select("project_chapter_id", selected: first_chapter.name, disabled: false)
      expect(page).to have_button("Apply", disabled: false)
    end

    it "preserves saved questions and answers when a trustee changes chapters" do
      project = FactoryBot.create(:project, chapter: first_chapter, extra_question_1: "Stored question?", extra_answer_1: "Stored answer", extra_question_2: "Another stored question?", extra_answer_2: "Another answer", extra_question_3: "Unanswered stored question?")
      user = FactoryBot.create(:user, admin: true, password: "12345")
      visit sign_in_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "12345"
      click_button "Sign in"
      visit edit_project_path(project)
      expect(page).to have_field("Stored question?", with: "Stored answer")
      expect(page).not_to have_field("First chapter question?")

      select second_chapter.name, from: "project_chapter_id"
      expect(page).to have_field("Stored question?", with: "Stored answer")
      expect(page).to have_field("Another stored question?", with: "Another answer")
      expect(page).to have_field("Unanswered stored question?", with: "")
      expect(page).not_to have_field("Second chapter question?")
      expect(project.reload.chapter).to eq(first_chapter)
      expect(page).to have_current_path(edit_project_path(project))
      expect(project.extra_answer_1).to eq("Stored answer")
      click_button "Save"
      expect(page).to have_current_path(chapter_project_path(second_chapter, project), ignore_query: true)
      expect(project.reload.chapter).to eq(second_chapter)
      expect(project.extra_question_1).to eq("Stored question?")
      expect(project.extra_answer_1).to eq("Stored answer")
      expect(project.extra_question_2).to eq("Another stored question?")
      expect(project.extra_answer_2).to eq("Another answer")
      expect(project.extra_question_3).to eq("Unanswered stored question?")
      expect(project.extra_answer_3).to be_blank
    end
  end
end
