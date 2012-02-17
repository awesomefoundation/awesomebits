require 'open-uri'

class RSS
  attr_reader :raw_xml

  def initialize(feed_url)
    begin
      @raw_xml = open(feed_url, "UserAgent" => "Ruby-OpenURI").read
    rescue
      @raw_xml = ''
    end
  end

end
