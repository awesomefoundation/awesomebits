require 'nokogiri'

class Headline
  attr_reader :raw_xml, :headlines

  def initialize(raw_xml)
      @raw_xml = raw_xml
      parse_xml
  end

  def parse_xml
    begin
      doc = Nokogiri.XML(raw_xml)
      @headlines = doc.xpath('//rss/channel/item').map do |i| {
        :title        => i.xpath('title').text,
        :link         => i.xpath('link').text,
        :description  => i.xpath('description').text.squish,
        :publish_date => i.xpath('pubDate').text }
      end
    rescue
      @headlines = []
    end
  end

  def top(num_items)
    @headlines.first(num_items)
  end

end
