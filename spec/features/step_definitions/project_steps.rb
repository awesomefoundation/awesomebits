step 'I am looking at the list of projects' do
  visit submissions_path
end

step 'I go back to the first page of projects' do
  visit submissions_path
end

step 'I am looking at the list of projects for the first chapter' do
  visit chapter_projects_path(@my_chapter)
end

step 'I am looking at the list of projects for the current chapter' do
  visit chapter_projects_path(@current_chapter)
end

step 'a project was created on each of the last 7 days for my chapter' do
  @my_projects = []
  7.times do |x|
    @my_projects << FactoryGirl.create(:project,
                           :chapter => @current_chapter,
                           :created_at => x.days.ago)
  end
end

step 'a project was created on each of the last 50 days for my chapter and I voted for them all' do
  @my_projects = []
  50.times do |x|
    @my_projects << FactoryGirl.create(:project,
                           :chapter => @current_chapter,
                           :created_at => x.days.ago)

    FactoryGirl.create(:vote, :project => @my_projects.last, :user => @current_user)
  end
end

step 'a project was created on each of the last 7 days for one chapter' do
  @my_chapter = FactoryGirl.create(:chapter)
  @my_projects = []
  7.times do |x|
    @my_projects << FactoryGirl.create(:project,
                           :chapter => @my_chapter,
                           :created_at => x.days.ago)
  end
end

step 'a project was created on each of the last 7 days for a different chapter' do
  @other_chapter = FactoryGirl.create(:chapter)
  @other_projects = []
  7.times do |x|
    @other_projects << FactoryGirl.create(:project,
                              :chapter => @other_chapter,
                              :created_at => x.days.ago)
  end
end

step 'a project was created on each of the last 7 days for any chapter' do
  any_chapter = Chapter.find_by_name("Any") || raise("'Any' chapter not found")
  @any_projects = []
  7.times do |x|
    @any_projects << FactoryGirl.create(:project, {
      :chapter => any_chapter,
      :created_at => x.days.ago
    })
  end
end

step 'I want to see my projects for the past 3 days' do
  fill_in("end date", :with => Time.now.utc.strftime("%Y-%m-%d"))
  fill_in("start date", :with => (3.days.ago.utc).strftime("%Y-%m-%d"))
  click_button("Filter")
end

step 'I should see my projects for the past 3 days' do
  expected = @my_projects[0..3]
  expected.each do |project|
    expect(page).to have_css(".project .title:contains('#{project.title}')")
  end
end

step 'I should not see projects that are not mine' do
  not_expected = @other_projects + @any_projects
  not_expected.each do |project|
    expect(page).to have_no_css(".project .title:contains('#{project.title}')")
  end
end

step 'I should not see any projects that are 4 or more days old' do
  not_expected = @my_projects[4..-1]
  not_expected.each do |project|
    expect(page).to have_no_css(".project .title:contains('#{project.title}')")
  end
end

step 'I look at the projects for the "Any" chapter' do
  page.find(:css, "a.chapter-selection").click
  page.find(:css, "ol.chapter-selector li a", text: "Any").click
  @viewing_projects = @any_projects
end

step 'I look at the projects for the other chapter' do
  page.find(:css, "ol.chapter-selector li a:contains('#{@other_chapter.name}')").click
  @viewing_projects = @other_projects
end

step 'I should see its projects for the past 3 days' do
  expected = @viewing_projects[0..3]
  expected.each do |project|
    expect(page).to have_css(".project .title:contains('#{project.title}')")
  end
end

step 'I view the project in the admin area' do
  visit(chapter_projects_path(@current_chapter))
end

step 'I should see the questions and my answers to them' do
  question_1 = page.find(:css, ".project-pitch h3", text: @extra_question_1).find(:xpath, "./..")
  expect(question_1).to have_css("p", text: @extra_answer_1)

  question_2 = page.find(:css, ".project-pitch h3", text: @extra_question_2).find(:xpath, "./..")
  expect(question_2).to have_css("p", text: @extra_answer_2)

  question_3 = page.find(:css, ".project-pitch h3", text: @extra_question_3).find(:xpath, "./..")
  expect(question_3).to have_css("p", text: @extra_answer_3)
end

step 'I go to the recently submitted project' do
  visit(project_path(Project.last))
end

step 'there is/are :count winning project(s)' do |count|
  count = count.to_i
  @projects = (1..count).map{|x| FactoryGirl.create(:project_with_rss_feed, :funded_on => x.days.ago) }
end

step 'there is 1 winning project in my chapter' do
  @project = FactoryGirl.create(:winning_project, :chapter => @current_chapter)
end

step 'there are enough winning projects in my chapter to spread over two pages' do
  FactoryGirl.create_list(:winning_project, Project.per_page + 1, :chapter => @current_chapter)
end

step 'I edit that winning project' do
  visit(project_path(@project))
  click_link "Edit Project"
end

step 'I should see those 5 winning projects in their proper order' do
  project_ids = @projects.sort_by(&:funded_on).reverse.map(&:id)
  css_selector = project_ids.map{|id| ".project-#{id}"}.join(" + ")
  expect(page).to have_css(".awesome-projects #{css_selector}")
end

step 'I should see only :count project(s)' do |count|
  expect(all('article.project').size).to eq(count.to_i)
end

step 'I click on that project' do
  page.find(:css, ".awesome-projects .image-wrapper").click
end

step 'I should see the page describing it and all its details' do
  project = @projects.first
  expect(page).to have_css(".projects-show")
  expect(page).to have_css("header h1:contains('#{project.title}')")
  expect(page).to have_css(".project-details .chapter-name a:contains('#{project.chapter.name}')")
  expect(page).to have_css(".project-details .project-starter:contains('#{project.name}')")
  expect(page).to have_css(".project-details p:contains('#{project.about_project}')")
  expect(page).to have_css(".project-side-bar .funded-on:contains('(#{project.funded_on.strftime("%B %Y")})')")
  expect(page).to have_css(".project-side-bar .project-site-link a[href='#{project.url}']")
end

step '5 projects have won for this chapter' do
  @winning_projects = (1..5).map do |x|
    FactoryGirl.create(:project, :chapter => @current_chapter, :funded_on => x.days.ago)
  end
end

step '5 projects have not won for this chapter' do
  @not_winning_projects = (1..5).map do |x|
    FactoryGirl.create(:project, :chapter => @current_chapter)
  end
end

step '5 projects have won, but not for this chapter' do
  @other_chapter = FactoryGirl.create(:chapter)
  @winning_projects_for_other_chapter = (1..5).map do |x|
    FactoryGirl.create(:project, :chapter => @other_chapter)
  end
end

step 'I should see only those 5 winning projects for this chapter listed' do
  @winning_projects_for_other_chapter.each do |project|
    expect(page).to have_no_css(".chapter-projects .project[data-id='#{project.id}']")
  end
  @not_winning_projects.each do |project|
    expect(page).to have_no_css(".chapter-projects .project[data-id='#{project.id}']")
  end
  @winning_projects.each do |project|
    expect(page).to have_css(".chapter-projects .project[data-id='#{project.id}'] a[href*='#{project_path(project)}']")
  end
end

step 'someone has submitted spam to my chapter' do
  @spam_project = FactoryGirl.create(:project, :chapter => @current_chapter)
end

step 'I go to the projects list' do
  visit(submissions_path)
end

step 'I delete the project' do
  page.find(:css, ".project[data-id='#{@spam_project.id}'] .delete-spam").click
end

step 'I should not see the project anymore' do
  expect(page).to have_no_css(".project[data-id='#{@spam_project.id}']")
end

step 'I go to the public page for that project' do
  visit(project_path(@project))
end

step 'I should see that 5 projects have been funded for $5000' do
  expect(page).to have_css(".what-how h2 .funding:contains('$5,000')")
  expect(page).to have_css(".what-how h2 .winners:contains('5')")
end

step 'that chapter has 5 winning projects' do
  @winning_projects = (1..5).map do |x|
    p = FactoryGirl.build(:project, :chapter => @current_chapter, :funded_on => x.months.ago)
    p.photos = [Photo.new(:image => File.new(Rails.root.join("spec", "support", "fixtures", "1.JPG")))]
    p.save
    p
  end
end

step 'I should see those 5 projects' do
  @winning_projects.each_with_index do |project, x|
    expect(page).to have_css(".image-wrapper img[src*='#{project.photos[0].image_file_name}']")
  end
end

step 'I should see when each has won' do
  @winning_projects.each_with_index do |project, x|
    expect(page).to have_css(".image-wrapper span:contains('#{I18n.l project.funded_on.to_date, :format => :funding}')")
  end
end

step 'I should see no feed for the project' do
  page.should have_no_css(".project-rss")
end

step 'I should be on the project page for that project' do
  expect(page.current_path).to eq(chapter_project_path(@current_chapter, @winning_project))
end

step 'I expand the project menu' do
  project = page.find("article.project", match: :first)
  project.find(".project-actions-toggle").click
end
