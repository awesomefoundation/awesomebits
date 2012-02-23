step 'I should see the project rss feed' do
  page.should have_selector("ol.feed li", :text => "New Melbourne Chapter")
end
