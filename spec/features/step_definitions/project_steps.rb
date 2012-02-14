step 'I am looking at the list of projects' do
  visit projects_path
end

step 'I am looking at the list of projects for the first chapter' do
  visit chapter_projects_path(@my_chapter)
end

step 'a project was created on each of the last 7 days for my chapter' do
  @my_projects = []
  7.times do |x|
    @my_projects << FactoryGirl.create(:project,
                                       :chapter => @current_chapter,
                                       :created_at => x.days.ago)
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
    @any_projects << FactoryGirl.create(:project,
                                        :chapter => any_chapter,
                                        :created_at => x.days.ago)
  end
end

step 'I want to see my projects for the past 3 days' do
  fill_in("end date", :with => Time.now.strftime("%Y-%m-%d"))
  fill_in("start date", :with => (3.days.ago).strftime("%Y-%m-%d"))
  click_button("Filter")
end

step 'I should see my projects for the past 3 days' do
  expected = @my_projects[0..3]
  expected.each do |project|
    page.should have_css(".project .title:contains('#{project.title}')")
  end
end

step 'I should not see projects that are not mine' do
  not_expected = @other_projects + @any_projects
  not_expected.each do |project|
    page.should_not have_css(".project .title:contains('#{project.title}')")
  end
end

step 'I should not see any projects that are 4 or more days old' do
  not_expected = @my_projects[4..-1]
  not_expected.each do |project|
    page.should_not have_css(".project .title:contains('#{project.title}')")
  end
end

step 'I look at the projects for the "Any" chapter' do
  page.find(:css, "ol.chapter-selector li a:contains('Any')").click
  @viewing_projects = @any_projects
end

step 'I look at the projects for the other chapter' do
  page.find(:css, "ol.chapter-selector li a:contains('#{@other_chapter.name}')").click
  @viewing_projects = @other_projects
end

step 'I should see its projects for the past 3 days' do
  expected = @viewing_projects[0..3]
  expected.each do |project|
    page.should have_css(".project .title:contains('#{project.title}')")
  end
end

step 'I view the project in the admin area' do
  visit(chapter_projects_path(@current_chapter))
  title = find(:css, "a.title:contains('#{@project_title}')")
  title.find(:xpath, "./../../..").find(:css, "a.see-more").click
end

step 'I should see the questions and my answers to them' do
  question_1 = page.find(:css, ".question h2:contains('#{@extra_question_1}')").find(:xpath, "./..")
  question_1.should have_css(".answer:contains('#{@extra_answer_1}')")

  question_2 = page.find(:css, ".question h2:contains('#{@extra_question_2}')").find(:xpath, "./..")
  question_2.should have_css(".answer:contains('#{@extra_answer_2}')")

  question_3 = page.find(:css, ".question h2:contains('#{@extra_question_3}')").find(:xpath, "./..")
  question_3.should have_css(".answer:contains('#{@extra_answer_3}')")
end

step 'I go to the recently submitted project' do
  visit(project_path(Project.last))
end
