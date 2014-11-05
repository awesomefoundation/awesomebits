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

  context 'with an image with a utf-8 encoded filename' do
    let(:photo) { FactoryGirl.create(:utf8_photo) }

    it "returns a dynamic photo url that is escaped properly" do
      photo.url(:main).should match(/#{CGI.escape(URI.unescape(photo.url))}/)
    end
  end

  context 'with a direct upload url' do
    before(:each) do
      Fog.mock!
      Fog::Mock.reset
    end

    let(:uploaded_image) { FogFactory.new.create_png_file }
    let(:uploaded_image_with_space) { FogFactory.new.create_png_file(:key => "with space.png") }
    let(:uploaded_image_with_restricted_character) { FogFactory.new.create_png_file(:key => "with[bracket].png") }
    let(:photo) { FactoryGirl.build(:photo, :image => nil) }
    
    it "copies a direct upload url to the correct destination" do
      photo.fog_config = FogFactory.fog_config
      photo.direct_upload_url = uploaded_image.public_url
      photo.save

      photo.image.should_not be_nil
      photo.image.size.should == uploaded_image.content_length
      photo.image.updated_at.should == Time.parse(uploaded_image.last_modified).to_i
      photo.image.content_type.should == uploaded_image.content_type
      File.basename(photo.url).should == File.basename(uploaded_image.public_url)
    end

    it "handles images with escaped spaces in its name" do
      photo.fog_config = FogFactory.fog_config
      photo.direct_upload_url = uploaded_image_with_space.public_url
      photo.save

      photo.image.should_not be_nil
      File.basename(photo.url).should == "with_space.png"
    end

    it "handles images with restricted characters in its name" do
      photo.fog_config = FogFactory.fog_config
      photo.direct_upload_url = uploaded_image_with_restricted_character.public_url
      photo.save

      photo.image.should_not be_nil
      File.basename(photo.url).should == "with_bracket_.png"
    end
  end
end
