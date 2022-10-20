class Photo < ApplicationRecord
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

  # To inject different Shrine storages during testing
  attribute :storage_keys, default: {}

  scope :sorted, -> { order(sort_order: :asc, id: :asc) }
  scope :image_files, -> { where(Photo.arel_table[:image_content_type].matches('image/%')).or(where(Arel.sql("image_data->'metadata'->>'mime_type' LIKE 'image/%'"))) }

  belongs_to :project, optional: true

  include ImageUploader::Attachment(:image)

  after_create do
    DirectUploadJob.new.async.perform(self)
  end

  def image?
    image && image.content_type.to_s.match?(/^image\//)
  end

  # Build a URL to dynamically resize images via an external service
  # or return the default image if we don't have an attached image
  def url(size = nil)
    if crop = DIMENSIONS[size]
      image.present? ? cropped_image_url(crop) : image_attacher.url(derivative: size)

    else
      image_attacher.url
    end
  end

  def transfer_from_direct_upload
    if persisted? && direct_upload_url.present?
      # Assign the remote file as the Shrine :cache upload
      set_attributes_from_direct_upload

      # self.direct_upload_url = nil

      # This save will trigger Shrine to copy from :cache to :store
      save

      # TODO: Remove the original cache file?
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

  def shrine_cache
    ImageUploader.storages[image_attacher.cache_key]
  end

  def set_attributes_from_direct_upload
    file = shrine_cache.object(direct_upload_path)

    uploaded_file = Shrine.uploaded_file(
      storage: image_attacher.cache_key,
      id: direct_upload_path,
      metadata: {
        size: file.content_length,
        filename: File.basename(direct_upload_path),
        mime_type: file.content_type
      }
    )

    image_attacher.change(uploaded_file)
  end

  # S3 URLs come in with spaces escaped, so we have to unescape them to get the
  # actual path in the bucket.
  def direct_upload_path
    path = CGI.unescape(URI(direct_upload_url).path[1..-1])
    path.sub!(%r{^#{shrine_cache.prefix}/}, "") if shrine_cache.try(:prefix)
  end
end
