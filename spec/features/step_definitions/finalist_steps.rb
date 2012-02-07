step 'I view the finalists for this month' do
  visit(chapter_finalists_path(@current_user.chapters.first))
end

step 'I should only see the projects with votes in my chapter' do
  @finalist_projects.each do |project, count|
    page.should have_css("table tr td:contains('#{count}') + td:contains('#{project.title}')")
  end
end

step 'they should be in descending order of vote count' do
  counts = page.all("tr.finalist td:nth-child(2)").map(&:text)
  counts.should == counts.sort.reverse
end
