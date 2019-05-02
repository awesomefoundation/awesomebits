class Photo < ApplicationRecord
  DIMENSIONS = {
    main: "940x470",
    index: "500x300"
  }

  belongs_to :project, optional: true
  has_attached_file :image,
                    default_url: "no-image-:style.png"

  # Added when migrating to Paperclip 4.1 and since Paperclip
  # is deprecated, we will handle content validations later
  do_not_validate_attachment_file_type :image

  after_create do
    DirectUploadJob.new.async.perform(self)
  end

  cattr_accessor :fog_config
  self.fog_config = Rails.configuration.fog

  # Build a URL to dynamically resize application images via an external service
  # Currently using http://magickly.afeld.me/
  def url(size = nil)
    if crop = DIMENSIONS[size]
      image.present? ? cropped_image_url(crop) : image.url(size)

    else
      image_url
    end
  end

  def transfer_from_direct_upload
    if persisted? && direct_upload_url.present?
      set_attributes_from_direct_upload

      if uploaded_file = bucket.files.get(direct_upload_path)
        uploaded_file.copy(fog_config.bucket, image.path)

        destination_file = bucket.files.get(image.path)
        destination_file.public = true
        destination_file.save

        uploaded_file.destroy

        self.direct_upload_url = nil

        save
      end
    end
  end

  def original_url
    base_uri = URI(ENV['DEFAULT_URL'] || "http://localhost:3000")

    uri = URI(image_url)
    uri.scheme ||= base_uri.scheme
    uri.host   ||= base_uri.host
    uri.port   ||= base_uri.port

    uri.to_s
  end

  protected

  def image_url
    image.url(:original, :timestamp => false)
  end

  def cropped_image_url(crop)
    # [image_host, "q", image_path(crop)].join("/")

    cropper = ENV['THUMBOR_HOST'] ? :thumbor : :magickly
    ImageCropper.new(cropper, self).crop_url(crop)
  end

  def image_host
    ENV['MAGICKLY_HOST']
  end

  def image_path(crop)
    # We unescape before re-escaping because the URL that comes from Paperclip is already
    # escaped, so without unescaping, we'd be double-escaping the URL, which causes problems
    # especially with UTF-8 encoded filenames.
    [ "src", URI.unescape(original_url), "output", "jpg", "convert", "-auto-orient", "thumb", crop ].collect { |part| CGI.escape(part) }.join("/")
  end

  def fog
    @fog ||= Fog::Storage.new(fog_config.credentials)
  end

  def bucket
    @bucket ||= fog.directories.get(fog_config.bucket)
  end

  def set_attributes_from_direct_upload
    file = bucket.files.get(direct_upload_path)

    self.image_file_name = File.basename(direct_upload_path).gsub(image.options[:restricted_characters], "_")
    self.image_content_type = file.content_type
    self.image_file_size = file.content_length
    self.image_updated_at = file.last_modified
  end

  # S3 URLs come in with spaces escaped, so we have to unescape them to get the
  # actual path in the bucket.
  def direct_upload_path
    CGI.unescape(URI(direct_upload_url).path[1..-1])
  end
end
