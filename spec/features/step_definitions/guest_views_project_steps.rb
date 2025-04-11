step 'there is a project with :count photo(s)' do |count|
  @chapter = FactoryBot.create(:chapter)
  @project = FactoryBot.create(:project, :chapter => @chapter, :funded_on => 1.days.ago)
  FactoryBot.create_list(:photo, count.to_i,  :project => @project)
end

step 'I view the project' do
  visit funded_project_path(@project)
end

step 'I should see the placeholder image' do
  expect(page).to have_css('#project-gallery img[src^="/assets/no-image-large_rectangle"]')
end
