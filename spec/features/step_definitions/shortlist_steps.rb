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

step 'someone has voted for a project in another chapter' do
  FactoryGirl.create(:vote)
end

step ':count people/person have/has voted on a/another project in my chapter' do |count|
  @finalist_projects ||= []
  project = FactoryGirl.create(:project, :chapter => @current_chapter)
  @finalist_projects << [project, count] if count.to_i > 0
  count.to_i.times do |x|
    vote = FactoryGirl.create(:vote, :project => project)
    FactoryGirl.create(:role, :user => vote.user, :chapter => @current_chapter)
  end
end
