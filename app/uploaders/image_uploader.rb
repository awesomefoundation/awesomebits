class ImageUploader < Shrine
  ID_PARTITION_LIMIT = 1_000_000_000
  
  plugin :model
  plugin :activerecord
  plugin :cached_attachment_data
  plugin :default_url
  plugin :default_storage

  # Use local tus server in development and testing
  unless ENV["AWS_BUCKET"].present?
    storages[:cache] = storages[:tus]
  end

  Attacher.default_url do |derivative: nil, **|
    "no-image-#{derivative || "original"}.png"
  end

  Attacher.default_store {
    record.storage_keys[:store].presence || :store
  }

  Attacher.default_cache {
    record.storage_keys[:cache].presence || :cache
  }

  def generate_location(io, record: nil, name: nil, derivative: nil, metadata: {}, **)
    return super unless storage_key == record.image_attacher.store_key
    
    # photos/images/id/original/file

    if Shrine.storages[storage_key].is_a?(Shrine::Storage::S3)
      [
        record && record.class.name.underscore.pluralize,
        name.to_s.pluralize,
        record && record.id,
        derivative || "original",
        sanitize_name(io.original_filename)
      ].compact.join("/")

    else
      # public/system/photos/images/000/000/120/original/duck.0.jpg 
      [
        record && record.class.name.underscore.pluralize,
        name.to_s.pluralize,
        record && partitioned_id(record.id),
        derivative || "original",
        basic_location(io, metadata: metadata)
      ].compact.join("/")
    end
  end

  class Attacher
    private

    def activerecord_after_save
      super

      record.update_columns(
        image_file_name: File.basename(record.image.id),
        image_content_type: record.image.mime_type,
        image_file_size: record.image.size,
        image_updated_at: Time.current
      ) if record.image.present? && record.image.is_a?(Shrine::UploadedFile)
    end
  end

  private

  def sanitize_name(name)
    name&.gsub(/[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/, '_')
  end
  
  def partitioned_id(id)
    if id < ID_PARTITION_LIMIT
      ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
    else
      ("%012d".freeze % id).scan(/\d{3}/).join("/".freeze)
    end
  end
end
