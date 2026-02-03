step 'I shortlist a project' do
  # just choose the first project
  project_element = page.find(:css, "article.project", match: :first)
  @shortlisted_project_id = project_element['data-id'].to_i
  project_element.find(:css, "header a.short-list[data-chapter='#{@current_chapter.id}']").click
end

step 'I shortlist a project on the second page' do
  go_to_next_page
  project_element = page.find(:css, "article.project")
  @shortlisted_project_id = project_element['data-id'].to_i
  project_element.find(:css, "header a.short-list").click
end

step 'the project indicates that I have shortlisted it' do
  expect(page).to have_css("article.project[data-id='#{@shortlisted_project_id}'].shortlisted")
end

step 'the correct projects are displayed as shortlisted' do
  page.all(:css, "article.project:not([data-id='#{@shortlisted_project_id}'])").each do |el|
    expect(el['class']).not_to include('shortlisted')
  end
  expect(page).to have_css("article.project[data-id='#{@shortlisted_project_id}'].shortlisted")
end

step 'I de-shortlist that project' do
  page.find(:css, "article.project[data-id='#{@shortlisted_project_id}'] header a.short-list").click
end

step 'none of the projects should be shortlisted' do
  page.all(:css, "article.project").each do |el|
    expect(el['class']).not_to include('shortlisted')
  end
end

step 'someone has voted for a project in another chapter' do
  FactoryBot.create(:vote)
end

step ':count people/person have/has voted on a/another project in my chapter' do |count|
  @finalist_projects ||= []
  project = FactoryBot.create(:project, :chapter => @current_chapter, :created_at => count.to_i.days.ago)
  @finalist_projects << [project, count] if count.to_i > 0
  count.to_i.times do |x|
    role = FactoryBot.create(:role, :chapter => @current_chapter)
    vote = FactoryBot.create(:vote, :user => role.user, :project => project, :chapter => @current_chapter, :created_at => x.days.ago)
  end
end

step 'there are some projects for this month with votes' do
  role = FactoryBot.create(:role, :chapter => @current_chapter)
  3.times do
    project = FactoryBot.create(:project, :chapter => @current_chapter)
    FactoryBot.create(:vote, :user => role.user, :project => project, :chapter => @current_chapter)
  end
end

step 'there are some projects in the "Any" chapter for this month with votes' do
  @any_chapter = Chapter.where(:name => "Any").first
  role = FactoryBot.create(:role, :chapter => @current_chapter)
  3.times do
    project = FactoryBot.create(:project, :chapter => @any_chapter)
    FactoryBot.create(:vote, :user => role.user, :project => project, :chapter => @current_chapter)
  end
end

step 'I view the list of projects for this month' do
  visit(submissions_path)
end

step 'I view the list of projects for this month in the "Any" chapter' do
  visit(submissions_path)
  # make the menu visible
  page.find(".chapter-selection").click
  # then click it
  page.find(".chapter-selector a", :text => "Any").click
end

step 'I view only my shortlisted projects' do
  check('my-short-list')
  click_button('Filter')
end

step 'I should only see my shortlisted projects' do
  expect(page).to have_css('article.project', :visible => true, :count => 1)
  page.all(:css, "article.project", :visible => true).each do |el|
    expect(el['class']).to include('shortlisted')
  end
end

step 'I should see no projects' do
  expect(page).to have_no_css('article.project', :visible => true)
end

step 'the shortlisted filter should be on' do
  expect(find('#my-short-list')[:checked]).to be_present
end

step 'the shortlisted filter should be off' do
  expect(find('#my-short-list')[:checked]).to be_blank
end
