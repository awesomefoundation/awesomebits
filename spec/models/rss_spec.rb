require 'spec_helper'

describe RSS do

  def feed_xml(date = nil)
    xml = <<-end_xml
<rss>
  <channel>
    <item>
      <title>Title</title>
      <link>http://link</link>
      <pubDate>#{date ? date : 'Mon, 13 Feb 2012 04:03:56 +0000'}</pubDate>
    </item>
  </channel>
</rss>
    end_xml
  end

  context 'parsing valid XML' do
    let(:xml){ feed_xml }
    let(:rss){ RSS.new(xml) }
    let(:expected_headlines) do
      [{:title => "Title",
        :link => "http://link",
        :publish_date => Date.parse("Mon, 13 Feb 2012 04:03:56 +0000")}]
    end
    it 'returns the headlines of the RSS articles' do
      rss.headlines.should == expected_headlines
    end
  end

  context 'parsing empty XML' do
    let(:xml){ '' }
    let(:rss){ RSS.new(xml) }
    let(:expected_headlines){ [] }
    it 'returns a blank array for the RSS articles' do
      rss.headlines.should == expected_headlines
    end
  end

  context 'parsing invalid XML' do
    let(:xml){ '<a><b></a></b>' }
    let(:rss){ RSS.new(xml) }
    let(:expected_headlines){ [] }
    it 'returns a blank array for the RSS articles' do
      rss.headlines.should == expected_headlines
    end
  end

  context 'parsing xml that has an invalid date' do
    let(:xml){ feed_xml("bad date") }
    let(:rss){ RSS.new(xml) }
    let(:expected_headlines) do
      [{:title => "Title",
        :link => "http://link",
        :publish_date => Date.today}]
    end
    it 'returns a blank array for the RSS articles' do
      rss.headlines.should == expected_headlines
    end
  end

end
