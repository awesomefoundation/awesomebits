step 'there is news on the main news feed' do
  uri = URI.parse(MAIN_AWESOME_RSS)
  @feed_path = Rails.root.join("spec", "support", "feed.xml")
  app = ShamRack.at(uri.host).stub
  app.register_resource(uri.path, File.read(@feed_path), "text/xml")
end

step 'I should see the news from the feed on the homepage' do
  RSS.new(Fetcher.new(@feed_path).to_s).headlines.first(6).each do |headline|
    page.should have_css(".feed-wrapper a:contains('#{headline[:title]}')")
  end
end
