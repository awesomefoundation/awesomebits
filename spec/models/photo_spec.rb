require 'spec_helper'
require 'paperclip/matchers/have_attached_file_matcher'

describe Photo do
  it { expect(subject).to belong_to :project }
  it { expect(subject).to have_attached_file :image }

  context 'with an image' do
    let(:photo) { FactoryGirl.create(:photo) }

    it "returns the base photo url as the original photo" do
      expect(photo.url).to eq(photo.image.url(:original, :timestamp => false))
    end

    it "returns a dynamic photo url as a cropped photo" do
      expect(photo.url(:main)).to match(/#{ENV['MAGICKLY_HOST']}/)
      expect(photo.url(:main)).to match(/thumb\/#{CGI.escape(Photo::MAIN_DIMENSIONS)}/)
      expect(photo.url(:main)).to match(/#{CGI.escape(photo.url)}/)
    end
  end

  context 'with an image with a utf-8 encoded filename' do
    let(:photo) { FactoryGirl.create(:utf8_photo) }

    it "returns a dynamic photo url that is escaped properly" do
      expect(photo.url(:main)).to match(/#{CGI.escape(URI.unescape(photo.url))}/)
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

      expect(photo.image).not_to be_nil
      expect(photo.image.size).to eq(uploaded_image.content_length)
      expect(photo.image.updated_at).to eq(Time.parse(uploaded_image.last_modified).to_i)
      expect(photo.image.content_type).to eq(uploaded_image.content_type)
      expect(File.basename(photo.url)).to eq(File.basename(uploaded_image.public_url))
    end

    it "handles images with escaped spaces in its name" do
      photo.fog_config = FogFactory.fog_config
      photo.direct_upload_url = uploaded_image_with_space.public_url
      photo.save

      expect(photo.image).not_to be_nil
      expect(File.basename(photo.url)).to eq("with_space.png")
    end

    it "handles images with restricted characters in its name" do
      photo.fog_config = FogFactory.fog_config
      photo.direct_upload_url = uploaded_image_with_restricted_character.public_url
      photo.save

      expect(photo.image).not_to be_nil
      expect(File.basename(photo.url)).to eq("with_bracket_.png")
    end
  end
end
