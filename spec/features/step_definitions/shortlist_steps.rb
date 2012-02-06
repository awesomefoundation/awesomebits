step 'I shortlist a project' do
  project_element = page.find(:css, "article.project")
  @shortlisted_project_id = project_element['data-id'].to_i
  project_element.find(:css, "header a.short-list").click
end

step 'the project indicates that I have shortlisted it' do
  page.should have_css("article.project[data-id='#{@shortlisted_project_id}'].shortlisted")
end

step 'the correct projects are displayed as shortlisted' do
  page.all(:css, "article.project:not([data-id='#{@shortlisted_project_id}'])").each do |el|
    el['class'].should_not include('shortlisted')
  end
  page.should have_css("article.project[data-id='#{@shortlisted_project_id}'].shortlisted")
end

step 'I de-shortlist that project' do
  page.find(:css, "article.project[data-id='#{@shortlisted_project_id}'] header a.short-list").click
end

step 'none of the projects should be shortlisted' do
  page.all(:css, "article.project").each do |el|
    el['class'].should_not include('shortlisted')
  end
end
