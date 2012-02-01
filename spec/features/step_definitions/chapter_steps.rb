step 'I create a new chapter' do
  click_link("Create Chapter")
  @chapter_name = "Another Awesome Chapter"
  fill_in("Name", :with => @chapter_name)
  fill_in("Twitter URL", :with => "http://twitter.com/awesomefound")
  fill_in("Facebook URL", :with => "http://twitter.com/awesomefound")
  fill_in("Blog URL", :with => "http://twitter.com/awesomefound")
  fill_in("Description", :with => "http://twitter.com/awesomefound")
  click_button("Create Chapter")
end

step 'I go to the chapters index' do
  visit(chapters_url)
end

step 'I should see this new chapter' do
  page.should have_css(".chapter .name:contains('#{@chapter_name}')")
end
