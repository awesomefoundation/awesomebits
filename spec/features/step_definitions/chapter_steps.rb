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

step 'I click on a chapter I am dean of' do
  click_link(@current_chapter.name)
end

step 'I click on the edit link' do
  click_link('Edit Chapter')
end

step 'I edit the chapter' do
  @new_chapter_name = "Montecito"
  fill_in("Name", :with => @new_chapter_name)
  click_button("Update Chapter")
end

step 'I should see the updated chapter page' do
  page.should have_content(@new_chapter_name)
end

