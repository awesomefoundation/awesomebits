require 'open-uri'

class Fetcher

  def initialize(url)
    @url = url
  end

  def to_s
    begin
      open(@url).read
    rescue SocketError
      ""
    rescue OpenURI::HTTPError
      ""
    rescue Errno::ENOENT
      ""
    end
  end

end
