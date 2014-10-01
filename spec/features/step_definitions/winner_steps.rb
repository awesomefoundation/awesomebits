step 'I pick a winner' do
  project = page.find("article.project", match: :first)
  @winning_project = Project.find(project['data-id'])
  project.find(".mark-as-winner").click
end

step 'I pick a winner for my chapter' do
  project = page.find("article.project", match: :first)
  @winning_project = Project.find(project['data-id'])
  project.find(".mark-as-winner.chapter-#{@current_chapter.id}").click
end

step 'I revoke the win from that project' do
  project_element = page.find("article.winner[data-id='#{@winning_project.id}']")
  project_element.find(".mark-as-winner").click
end

step 'the project is no longer visible to the public' do
  click_link("Sign out")
  visit(project_path(@winning_project))
  page.should have_no_content(@winning_project.title)
end

step 'the project is visible to the public' do
  click_link("Sign out")
  visit(project_path(@winning_project))
  page.should have_css("body.projects")
  page.should have_content(@winning_project.title)
end

step 'the winning project should look triumphant' do
  page.should have_css("article.winner[data-id='#{@winning_project.id}']")
end

step 'the project looks normal' do
  page.should have_no_css("article.winner[data-id='#{@winning_project.id}']")
  page.should have_css("article[data-id='#{@winning_project.id}']")
end

step 'the winning project should belong to my chapter' do
  visit(project_path(@winning_project))
  page.should have_css(".meta-data p", text: "#{@current_chapter.name} project")
end
