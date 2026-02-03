require 'spec_helper'

describe ImageCropper do
  let(:main_crop) { Photo::DIMENSIONS[:main] }

  context "Magickly" do
    before(:each) do
      @cropper = ImageCropper.new(:magickly, photo)
      @cropper.host = "http://magickly.example.com"
    end

    context "with a regular photo" do
      let(:photo) { FactoryBot.create(:photo) }

      it "generates a Magickly URL" do
        url = @cropper.crop_url(main_crop)

        expect(url).to match(/#{@cropper.host}/)
        expect(url).to match(/thumb\/#{CGI.escape("#{main_crop}#")}/)
        expect(url).to match(/#{CGI.escape(photo.url)}/)
      end
    end

    context "with a utf-8 encoded filename" do
      let(:photo) { FactoryBot.create(:utf8_photo) }

      it "generates a Magickly URL with an escaped filename" do
        expect(@cropper.crop_url(main_crop)).to match(/#{CGI.escape(Addressable::URI.unescape(photo.original_url))}/)
      end
    end
  end

  context "Thumbor" do
    before(:each) do
      @cropper = ImageCropper.new(:thumbor, photo)
      @cropper.host = "http://thumbor.example.com"
    end

    context "with a regular photo" do
      let(:photo) { FactoryBot.create(:photo) }

      it "generates a Thumbor URL" do
        url = @cropper.crop_url(main_crop)

        expect(url).to match(/#{@cropper.host}/)
        expect(url).to match(/#{main_crop}\/smart/)
        expect(url).to match(/#{photo.url}/)
      end
    end

    context "with a utf-8 encoded filename" do
      let(:photo) { FactoryBot.create(:utf8_photo) }

      it "generates a Thumbor URL without an escaped filename" do
        expect(@cropper.crop_url(main_crop)).to match(/#{Addressable::URI.unescape(photo.original_url)}/)
      end
    end
  end
end
