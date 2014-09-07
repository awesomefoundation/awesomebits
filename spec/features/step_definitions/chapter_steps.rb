step 'I create a new chapter' do
  click_link("Create a Chapter")
  @chapter_name = "Another Awesome Chapter"
  fill_in("Name", :with => @chapter_name)
  fill_in("Twitter URL", :with => "http://twitter.com/awesomefound")
  fill_in("Facebook URL", :with => "http://twitter.com/awesomefound")
  fill_in("Blog URL", :with => "http://twitter.com/awesomefound")
  fill_in("RSS Feed URL", :with => "http://awesomefoundation.org/blog/feed/")
  fill_in("Description", :with => "http://twitter.com/awesomefound")
  select("United States", :from => "Country")
  click_button("Create Chapter")
end

step 'I go to create a new chapter' do
  click_link("Create a Chapter")
end

step 'I just submit the form' do
  click_button("Create Chapter")
end

step 'I should see the new chapter form with errors' do
  page.should have_css(".field_with_errors label:contains('* Name')")
  page.should have_css(".field_with_errors label:contains('* Description')")
end

step 'there is a chapter in the system' do
  @current_chapter = FactoryGirl.create(:chapter, :rss_feed_url => Rails.root.join('spec', 'support', 'feed.xml').to_s)
end

step 'I go to the chapter page' do
  visit chapter_path(@current_chapter)
end

step 'I enter new questions for applicants to answer' do
  @extra_question_1 = "What is your name?"
  fill_in("Extra question 1", :with => @extra_question_1)
  @extra_question_2 = "What is your quest?"
  fill_in("Extra question 2", :with => @extra_question_2)
  @extra_question_3 = "What is the airspeed velocity of an unladen swallow?"
  fill_in("Extra question 3", :with => @extra_question_3)
  click_button("Update")
end

step 'I enter different questions for applicants to answer' do
  fill_in("Extra question 1", :with => "New Stuff 1")
  fill_in("Extra question 2", :with => "New Stuff 2")
  fill_in("Extra question 3", :with => "New Stuff 3")
  click_button("Update")
end

step 'I go to the chapters index' do
  visit(chapters_url)
end

step 'I should not see the Any chapter' do
  page.should_not have_css("h2.name:contains('Any')")
end

step 'I should see this new chapter' do
  page.should have_content(@chapter_name)
end

step 'I edit a chapter' do
  visit(chapters_url)
  click_link(@current_chapter.name)
  click_link('Edit Chapter')
  @new_chapter_name = "Montecito"
  @new_twitter_url = "http://twitter.com/awesomefound"
  @new_facebook_url = "http://facebook.com/awesomefound"
  @new_email_address = "new@example.com"
  @new_blog_url = "http://blog.com/awesomefound"
  @new_rss_feed_url = "http://rss.com/awesomefound"
  @new_description = "This is a description of the chapter."
  fill_in("Name",           :with => @new_chapter_name)
  fill_in("Twitter URL",    :with => @new_twitter_url)
  fill_in("Facebook URL",   :with => @new_facebook_url)
  fill_in("Email Address",  :with => @new_email_address)
  fill_in("Blog URL",       :with => @new_blog_url)
  fill_in("RSS Feed URL",   :with => @new_rss_feed_url)
  fill_in("Description",    :with => @new_description)
  click_button("Update Chapter")
end

step 'I should see the updated chapter' do
  page.should have_css("h1:contains('#{@new_chapter_name}')")
  page.should have_css("a.twitter[href='#{@new_twitter_url}']")
  page.should have_css("a.facebook[href='#{@new_facebook_url}']")
  page.should have_css("a.email[href='mailto:#{@new_email_address}']")
  page.should have_css("a.blog[href='#{@new_blog_url}']")
  page.should have_css("article.rss-feed[data-feed-url='#{@new_rss_feed_url}']")
  page.should have_css(".about p:contains('#{@new_description}')")
end

step 'I attempt to edit a/my chapter' do
  visit(edit_chapter_path(@current_chapter))
end

step 'I should see a permissions error' do
  page.should have_content('You must be an admin or dean to access this page.')
end

step 'there are 5 chapters' do
  @chapters = (1..5).map{ FactoryGirl.create(:chapter) }
end

step "those projects' chapters are in 4 countries total" do
  countries = ['United States', 'United States', 'Canada', 'United Kingdom', 'Spain']
  @projects.each_with_index{|p, i| p.chapter.update_attribute(:country, countries[i]) }
end

step 'I should see those 5 chapters' do
  @projects.each do |project|
    page.should have_css(".awesome-chapters a:contains('#{project.chapter.name}')")
  end
end

step 'I should see that the 6 chapters, including Any, are spread across 4 countries' do
  page.should have_css(".who-where h2 .chapters:contains('6')")
  page.should have_css(".who-where h2 .countries:contains('4')")
end
