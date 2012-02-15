step 'I pick a winner' do
  project = page.find("article.project")
  @winning_project = Project.find(project['data-id'])
  project.find(".mark-as-winner").click
end

step 'I revoke the win from that project' do
  project_element = page.find("article.winner[data-id='#{@winning_project.id}']")
  project_element.find(".mark-as-winner").click
end

step 'the project is no longer visible to the public' do
  click_link("Sign out")
  visit(project_path(@winning_project))
  page.should have_no_css("body.projects")
  page.should have_no_content(@winning_project.title)
end

step 'the project is visible to the public' do
  click_link("Sign out")
  visit(project_path(@winning_project))
  page.should have_css("body.projects")
  page.should have_content(@winning_project.title)
end

step 'the submitter of the project gets an email saying they won' do
  deliveries = ActionMailer::Base.deliveries.select do |mail|
    mail.subject =~ /Your project won!/ && mail.to.include?(@winning_project.email)
  end

  deliveries.should have(1).item
end

step 'the winning project should look triumphant' do
  page.should have_css("article.winner[data-id='#{@winning_project.id}']")
end

step 'the project looks normal' do
  page.should have_no_css("article.winner[data-id='#{@winning_project.id}']")
  page.should have_css("article[data-id='#{@winning_project.id}']")
end
