step 'I view the finalists for this month' do
  visit(chapter_finalists_path(@current_user.chapters.first))
end

step 'I view the finalists for the first chapter' do
  visit(chapter_finalists_path(@current_chapter))
  page.should have_content("Finalists for #{@current_chapter.name}")
end

step 'I select the other chapter from the navigation dropdown' do
  page.find(".chapter-selector li a:contains('#{@other_chapter.name}')").click
end

step 'I should see the finalists for the other chapter' do
  page.should have_content("Finalists for #{@other_chapter.name}")
end

step "I look at the other chapter's finalists" do
  visit(chapter_finalists_path(@other_current_chapter))
end

step "I look at my chapter's finalists" do
  visit(chapter_finalists_path(@current_chapter))
end

step 'I should only see the projects with votes in my chapter' do
  @finalist_projects.each do |project, count|
    page.should have_css("table tr[data-count='#{count}'] td a:contains('#{project.title}')")
  end
end

step 'they should be in descending order of vote count' do
  counts = page.all("tr.finalist td:nth-child(3)").map(&:text)
  counts.should == counts.sort.reverse
end

step 'votes are cast once per day, consecutively leading up to today' do
end

step 'projects are created the day of the first vote is cast' do
end

step 'I filter the finalists to only show the day before yesterday' do
  fill_in("start date", :with => 2.days.ago.strftime("%Y-%m-%d"))
  fill_in("end date", :with => 2.days.ago.strftime("%Y-%m-%d"))
  click_button("Filter")
end

step 'I should see that 2 votes were cast on projects created in that time' do
  vote_count = page.all(:css, "table tr td:nth-child(3)").map(&:text).map(&:to_i).sum
  vote_count.should == 2
end

step 'I should see the project I shortlisted' do
  page.should have_css("tr.finalist[data-id='#{@shortlisted_project_id}']")
end
