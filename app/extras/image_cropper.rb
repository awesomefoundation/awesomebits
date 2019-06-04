class ImageCropper
  # Host can be set explicitly for testing purposes
  # (so we don't have to set ENV in the test suite)
  attr_accessor :host

  # service can be one of [:magickly, :thumbor]
  # photo is a Photo object
  def initialize(service, photo)
    service = "ImageCropper::#{service.to_s.classify}".constantize

    @cropper = service.new(photo)
  end

  def crop_url(crop)
    [ cropper_host, @cropper.path(crop) ].join("/")
  end

  protected

  def cropper_host
    self.host || @cropper.host
  end

  class Magickly
    def initialize(photo)
      @photo = photo
    end

    def host
      ENV.fetch("MAGICKLY_HOST")
    end

    def path(crop)
      # We unescape before re-escaping because the URL that comes from Paperclip is already
      # escaped, so without unescaping, we'd be double-escaping the URL, which causes problems
      # especially with UTF-8 encoded filenames.
      [
        "q",
        "src", URI.unescape(@photo.original_url),
        "output", "jpg",
        "convert", "-auto-orient",
        "thumb", "#{crop}#{'#' if crop.match(/\d$/)}",
      ].collect { |part| CGI.escape(part) }.join("/")
    end
  end

  class Thumbor
    def initialize(photo)
      @photo = photo
    end

    def host
      ENV.fetch("THUMBOR_HOST")
    end

    def path(crop)
      [ "unsafe", crop_string(crop), "smart", URI.unescape(@photo.original_url) ].join("/")
    end

    protected

    # Turn ImageMagick geometry into Thumbor geometry
    def crop_string(crop)
      if crop.match(/\d+x\d+/)
        crop
      elsif crop.match(/>/)
        # In ImageMagick, this means only crop if the image is larger
        # than the crop size. If we are specifying this, we don't want
        # to scale up. Thumbor doesn't know how to not scale up, so in
        # the abesence of image metadata, just don't scale in this case
        "0x0"
      elsif m = crop.match(/^(\D*)x(\d+)/)
        "0x#{m[1]}"
      elsif m = crop.match(/^(\d+)x(\D*)$/)
        "#{m[1]}x0"
      else
        # If we can't handle the crop string, don't crop at all
        "0x0"
      end
    end
  end
end
