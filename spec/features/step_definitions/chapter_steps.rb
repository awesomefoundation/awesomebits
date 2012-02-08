step 'I create a new chapter' do
  click_link("Create Chapter")
  @chapter_name = "Another Awesome Chapter"
  fill_in("Name", :with => @chapter_name)
  fill_in("Twitter URL", :with => "http://twitter.com/awesomefound")
  fill_in("Facebook URL", :with => "http://twitter.com/awesomefound")
  fill_in("Blog URL", :with => "http://twitter.com/awesomefound")
  fill_in("RSS Feed URL", :with => "http://example.com/feed.rss")
  fill_in("Description", :with => "http://twitter.com/awesomefound")
  click_button("Create Chapter")
end

step 'I go to the chapters index' do
  visit(chapters_url)
end

step 'I should see this new chapter' do
  page.should have_css(".chapter .name:contains('#{@chapter_name}')")
end

step 'I edit a chapter' do
  visit(chapters_url)
  click_link(@current_chapter.name)
  click_link('Edit Chapter')
  @new_chapter_name = "Montecito"
  fill_in("Name", :with => @new_chapter_name)
  click_button("Update Chapter")
end

step 'I should see the updated chapter' do
  page.should have_content(@new_chapter_name)
end

step 'I attempt to edit a chapter' do
  visit(edit_chapter_path(@current_chapter))
end

step 'I should see a permissions error' do
  page.should have_content('You must be an admin or dean to access this page.')
end
