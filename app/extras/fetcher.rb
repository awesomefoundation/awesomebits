require 'open-uri'

class Fetcher

  def initialize(url)
    @url = url
  end

  def to_s
    begin
      open(@url).read
    rescue SocketError, OpenURI::HTTPError, Errno::ENOENT, Errno::ECONNREFUSED
      String.new
    end
  end

end
