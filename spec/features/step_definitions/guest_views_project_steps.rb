step 'I should see the project rss feed' do
  page.should have_selector("ol.feed li", :text => "New Melbourne Chapter")
end

step 'there is a project with :count photo(s)' do |count|
  @chapter = FactoryGirl.create(:chapter)
  @project = FactoryGirl.create(:project, :chapter => @chapter, :funded_on => 1.days.ago)
  count.to_i.times { FactoryGirl.create(:photo, :project => @project) }
end

step 'I view the project' do
  visit project_path(@project)
end

step 'I should not see the carousel buttons' do
  page.should_not have_css('.arrows')
end

step 'I should see the carousel buttons' do
  page.should have_css('.arrows')
end

