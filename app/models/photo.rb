class Photo < ApplicationRecord
  # TODO All this code can be removed once we migrate to Shrine
  cattr_accessor :shrine_uploads, default: ENV["SHRINE_UPLOADS"]

  DIMENSIONS = {
    main:            "940x470",
    index:           "500x300",
    large_rectangle: "940x470",
    small_rectangle: "470x235",
    large_square:    "470x470",
    small_square:    "235x235",
    gallery:         "2000x>",
  }

  MAX_FILE_SIZE = 20.megabytes

  scope :sorted, -> { order(sort_order: :asc, id: :asc) }
  scope :image_files, -> { where(Photo.arel_table[:image_content_type].matches('image/%')).or(where(Arel.sql("image_data->'metadata'->>'mime_type' LIKE 'image/%'"))) }

  belongs_to :project, optional: true

  if shrine_uploads
    include ImageUploader::Attachment(:image)
  else
    has_attached_file :image,
                      default_url: "no-image-:style.png"

    # https://shrinerb.com/docs/paperclip
    include PaperclipShrineSync

    # Added when migrating to Paperclip 4.1 and since Paperclip
    # is deprecated, we will handle content validations later
    do_not_validate_attachment_file_type :image
  end

  after_create do
    DirectUploadJob.new.async.perform(self)
  end

  cattr_accessor :fog_config
  self.fog_config = Rails.configuration.fog

  def image?
    image && image.content_type.to_s.match?(/^image\//)
  end

  # Build a URL to dynamically resize application images via an external service
  # Currently using http://magickly.afeld.me/
  def url(size = nil)
    if crop = DIMENSIONS[size]
      image.present? ? cropped_image_url(crop) : (shrine_uploads ? image_attacher.url(derivative: size) : image.url(size))

    else
      image_url
    end
  end

  def transfer_from_direct_upload
    if persisted? && direct_upload_url.present?
      set_attributes_from_direct_upload

      if shrine_uploads
        # self.direct_upload_url = nil
        save && return
      end

      if uploaded_file = bucket.files.head(direct_upload_path)
        uploaded_file.copy(fog_config.bucket, image.path)

        destination_file = bucket.files.head(image.path)
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

  def original_filename
    image&.original_filename || (direct_upload_url && File.basename(direct_upload_url))
  end

  protected

  def image_url
    if shrine_uploads
      super
    else
      image.url(:original, :timestamp => false)
    end
  end

  def cropped_image_url(crop)
    cropper = if ENV['IMGPROXY_HOST']
                :imgproxy
              elsif ENV['THUMBOR_HOST']
                :thumbor
              else
                :magickly
              end
    ImageCropper.new(cropper, self).crop_url(crop)
  end

  def fog
    @fog ||= Fog::Storage.new(fog_config.credentials)
  end

  def bucket
    @bucket ||= fog.directories.get(fog_config.bucket)
  end

  def set_attributes_from_direct_upload
    file = bucket.files.head(direct_upload_path)

    if shrine_uploads
      location = direct_upload_path
      location.sub!(%r{^#{Shrine.storages[:cache].prefix}/}, "") if Shrine.storages[:cache].try(:prefix)

      image_attacher.change Shrine.uploaded_file(
        storage: :cache,
        id: location,
        metadata: {
          size: file.content_length,
          filename: File.basename(direct_upload_path),
          mime_type: file.content_type
        }
      )
    else
      self.image_file_name = File.basename(direct_upload_path).gsub(image.options[:restricted_characters], "_")
      self.image_content_type = file.content_type
      self.image_file_size = file.content_length
      self.image_updated_at = file.last_modified
    end
  end

  # S3 URLs come in with spaces escaped, so we have to unescape them to get the
  # actual path in the bucket.
  def direct_upload_path
    CGI.unescape(URI(direct_upload_url).path[1..-1])
  end
end
