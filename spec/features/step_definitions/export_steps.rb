HEADER_COUNT = 1

step 'I visit a chapters projects page' do
  visit chapter_projects_path Chapter.last
end

step 'I export all projects' do
  click_link 'Export All From Date Range'
end

step 'I should not see the export all link' do
  page.should_not have_css('p', :text => 'Export All From Date Range')
end

step 'I filter to the last :num_days day(s)' do |num_days|
  fill_in("start date", with: (num_days.to_i.days.ago).utc.strftime("%Y-%m-%d"))
  fill_in("end date", with: Time.now.utc.strftime("%Y-%m-%d"))
  click_button "Filter"
end

step 'I should receive a CSV file with :num_projects projects' do |num_projects|
  csv = CSV.parse(page.source, :col_sep => ",")
  csv.count.should == (HEADER_COUNT + num_projects.to_i)
end
