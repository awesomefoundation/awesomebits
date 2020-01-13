step 'I pick a winner' do
  project = page.find("article.project", match: :first)
  @winning_project = Project.find(project['data-id'])
  project.click_link(I18n.t("projects.project.publish-as-winner"))
  fill_in("Funding date", with: 1.day.ago.strftime("%Y-%m-%d"))
  click_button(I18n.t("winners.edit.save"))
end

step 'I pick a winner for my chapter' do
  project = page.find("article.project", match: :first)
  @winning_project = Project.find(project['data-id'])
  project.click_link(I18n.t("projects.project.publish-as-winner"))
  fill_in("Funding date", with: 1.day.ago.strftime("%Y-%m-%d"))
  click_button(I18n.t("winners.edit.save"))
end

step 'I revoke the win from that project' do
  project_element = page.find("article.winner[data-id='#{@winning_project.id}']")
  project_element.click_link(I18n.t("projects.project.unpublish-as-winner"))
end

step 'the project is no longer visible to the public' do
  visit(project_path(@winning_project))
  expect(page).to have_no_content(@winning_project.title)
end

step 'the project is visible to the public' do
  visit(project_path(@winning_project))
  expect(page).to have_css("body.projects")
  expect(page).to have_content(@winning_project.title)
end

step 'the winning project should look triumphant' do
  expect(page).to have_css("article.winner[data-id='#{@winning_project.id}']")
end

step 'the project looks normal' do
  expect(page).to have_no_css("article.winner[data-id='#{@winning_project.id}']")
  expect(page).to have_css("article[data-id='#{@winning_project.id}']")
end

step 'the winning project should belong to my chapter' do
  visit(project_path(@winning_project))
  expect(page).to have_css(".meta-data p", text: "#{@current_chapter.name} project")
end
