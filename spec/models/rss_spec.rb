require 'spec_helper'

describe RSS do

  context 'given a valid feed url' do
    let(:feed_path) { Rails.root.join('spec', 'support', 'feed.xml') }
    let(:feed_contents) { RSS.new(feed_path).raw_xml }
    it 'should be an instance of string' do
      feed_contents.should be_an_instance_of String
    end
  end

  context 'given an invalid feed url' do
    let(:feed_url) { 'http://thoughtbot.com/notfound.xml' }
    let(:feed_contents) { RSS.new(feed_url).raw_xml }
    it 'should be an empty string' do
      feed_contents.should == ''
    end
  end

end
