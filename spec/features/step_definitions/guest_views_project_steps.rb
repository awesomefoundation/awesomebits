step 'there is a project with :count photo(s)' do |count|
  @chapter = FactoryGirl.create(:chapter)
  @project = FactoryGirl.create(:project, :chapter => @chapter, :funded_on => 1.days.ago)
  FactoryGirl.create_list(:photo, count.to_i,  :project => @project)
end

step 'I view the project' do
  visit project_path(@project)
end

step 'I should not see the carousel buttons' do
  expect(page).to have_no_css('.arrows')
end

step 'I should see the carousel buttons' do
  expect(page).to have_css('.arrows')
end

step 'I should see a placeholder image' do
  expect(page).to have_css('#project-gallery img[src="/assets/no-image-main.png"]')
end
