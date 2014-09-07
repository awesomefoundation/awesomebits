require 'spec_helper'
require 'paperclip/matchers/have_attached_file_matcher'

describe Photo do
  it { should belong_to :project }
  it { should have_attached_file :image }

  context 'with an image' do 
    let(:photo) { FactoryGirl.create(:photo) }

    it "returns the base photo url as the original photo" do 
      photo.url.should == photo.image.url(:original, :timestamp => false)
    end

    it "returns a dynamic photo url as a cropped photo" do 
      photo.url(:main).should match(/#{ENV['MAGICKLY_HOST']}/)
      photo.url(:main).should match(/thumb\/#{CGI.escape(Photo::MAIN_DIMENSIONS)}/)
      photo.url(:main).should match(/#{CGI.escape(photo.url)}/)
    end
  end
end
