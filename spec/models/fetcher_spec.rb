require 'spec_helper'

describe Fetcher do
  let(:file){ Rails.root.join("spec/support/feed.xml") }
  let(:contents){ File.read(file) }
  let(:url){ "http://example.com/feed.xml" }
  let(:http_error){ OpenURI::HTTPError.new(nil,nil) }

  it 'returns the contents of a file' do
    Fetcher.new(file).to_s.should == contents
  end

  it 'returns the contents of a URL' do
    app = ShamRack.at("example.com").stub
    app.register_resource("/feed.xml", contents, "text/xml")
    Fetcher.new(url).to_s.should == contents
  end

  it 'returns blank when there is a transport error' do
    fetcher = Fetcher.new(url)
    fetcher.stubs(:open).raises(http_error)
    fetcher.to_s.should == ""
  end

  it 'returns blank when there is a socket error' do
    fetcher = Fetcher.new(url)
    fetcher.stubs(:open).raises(SocketError)
    fetcher.to_s.should == ""
  end

  it 'returns blank when there is a connection refused error' do
    fetcher = Fetcher.new(url)
    fetcher.stubs(:open).raises(Errno::ECONNREFUSED)
    fetcher.to_s.should == ""
  end
end
