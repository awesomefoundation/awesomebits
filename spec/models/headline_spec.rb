require 'spec_helper'

describe Headline do
  let(:feed_path) { Rails.root.join('spec', 'support', 'feed.xml') }
  let(:xml) { RSS.new(feed_path).raw_xml }
  let(:headlines) { Headline.new(xml) }
  let(:expected_headlines) {
    [{:title        => 'New Melbourne Chapter',
      :link         => 'http://awesomefoundation.org/blog/2012/02/12/awesome-squared-welcome-to-melbourne/',
      :description  => 'The Awesome Foundation begins their second chapter in Melbourne, Awesome Squared, with five positions available for the taking. There are undeniably a lot of awesome things happening in Melbourne. We are after all, the most livable city in the world. That&#8217;s why the Awesome Foundation exists. So what if there was 2x as much Awesome? [...]',
      :publish_date => 'Mon, 13 Feb 2012 04:03:56 +0000'}]
  }

  context 'given an valid xml file' do
    it 'should return array of headlines' do
      headlines.top(1).should == expected_headlines
    end
  end

end
