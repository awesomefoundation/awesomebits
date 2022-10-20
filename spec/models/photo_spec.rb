# coding: utf-8
require 'spec_helper'

describe Photo do
  it { is_expected.to belong_to :project }

  context 'with an image' do
    let(:photo) { FactoryGirl.create(:photo) }

    it "returns the base photo url as the original photo" do
      expect(photo.url).to eq(photo.image.url)
    end

    it "returns a dynamic photo url as a cropped photo" do
      expect(photo.url(:main)).to match(/#{Photo::DIMENSIONS[:main]}/)
      expect(photo.url(:index)).to match(/#{Photo::DIMENSIONS[:index]}/)
    end
  end

  context "with S3 storage" do
    let(:image) { FakeData.fixture_file("1.JPG") }
    let(:photo) { FactoryGirl.create(:s3_photo, image: image) }

    it "can attach images" do
      expect(photo.image).to_not be_nil
    end

    it "is properly using the S3 mock storage" do
      expect(photo.image.storage_key).to eq(:s3_store)
    end

    context 'with an image with a utf-8 encoded filename' do
      let(:image) { FakeData.fixture_file("מדהים.png") }

      it "returns a dynamic photo url that is escaped properly" do
        expect(photo.url(:main)).to match(/#{CGI.escape(Addressable::URI.unescape(photo.url))}/)
      end
    end

    context 'with a direct upload url' do
      before do
        @aws_factory = AwsS3MockFactory.new(Shrine.storages[:s3_cache])
      end

      let(:key) { nil }
      let(:uploaded_image) { @aws_factory.create_mock_file(key: key) }
      let(:photo) { FactoryGirl.create(:s3_photo, image: nil, direct_upload_url: uploaded_image.public_url) }

      it "copies a direct upload url to the correct destination" do
        expect(photo.image.storage_key).to eq(photo.image_attacher.store_key)
        expect(photo.image).not_to be_nil
        expect(photo.image.size).to eq(uploaded_image.content_length)
        expect(photo.image.content_type).to eq(uploaded_image.content_type)
        expect(File.basename(photo.url)).to eq(File.basename(uploaded_image.public_url))
      end

      context "with an image with spaces in its name" do
        let(:key) { "with space.png" }

        it "replaces spaces with underscores" do
          expect(photo.image).not_to be_nil
          expect(File.basename(photo.url)).to eq("with_space.png")
        end
      end

      context "with an image with restricted characters" do
        let(:key) { "with[{bracket}].png" }

        it "replaces those characters with underscores" do
          expect(photo.image).not_to be_nil
          expect(File.basename(photo.url)).to eq("with__bracket__.png")
        end
      end
    end
  end
end
