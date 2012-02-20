class RSS
  def initialize(xml)
    @xml = xml
  end

  def headlines
    if @xml.blank?
      []
    else
      document.xpath('//rss/channel/item').map do |item|
        { :title        => item.xpath('title').text,
          :link         => item.xpath('link').text,
          :publish_date => extract_date(item.xpath('pubDate').text) }
      end
    end
  end

  private

  def extract_date(date_string)
    begin
      Date.parse(date_string)
    rescue ArgumentError => e
      Date.today
    end
  end

  def document
    @document ||= Nokogiri::XML.parse(@xml)
  end
end
