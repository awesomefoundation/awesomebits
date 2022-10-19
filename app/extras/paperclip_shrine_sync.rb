# require "shrine"
# require "shrine/storage/file_system"

# Shrine.storages = {
#   cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
#   store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),       # permanent 
# }

# Shrine.plugin :model
# Shrine.plugin :activerecord
# Shrine.plugin :derivatives

module PaperclipShrineSync
  def self.included(model)
    model.after_commit do
      Paperclip::AttachmentRegistry.each_definition do |klass, name, options|
        write_shrine_data(name) if saved_changes.key?(:"#{name}_file_name") && klass == self.class
      end
    end
  end

  def write_shrine_data(name)
    attachment = send(name)
    attacher   = ImageUploader::Attacher.from_model(self, name)

    if attachment.size.present?
      attacher.set shrine_file(attachment)

      attachment.styles.each do |style_name, style|
        attacher.merge_derivatives(style_name => shrine_file(style))
      end
    else
      attacher.set nil
    end

    attacher.send(:activerecord_after_save)
  end

  private

  def shrine_file(object)
    if object.is_a?(Paperclip::Attachment)
      shrine_attachment_file(object)
    else
      shrine_style_file(object)
    end
  end

  def shrine_attachment_file(attachment)
    location = attachment.path
    # if you're storing files on disk, make sure to subtract the absolute path
    location = location.sub(%r{^#{storage.prefix}/}, "") if storage.try(:prefix)
    location = location.sub(%r{^#{Shrine.storages[:store].directory}/}, "") if Shrine.storages[:store].respond_to?(:directory)

    Shrine.uploaded_file(
      storage:  :store,
      id:       location,
      metadata: {
        "size"      => attachment.size,
        "filename"  => attachment.original_filename,
        "mime_type" => attachment.content_type,
      }
    )
  end

  # If you'll be using a `:prefix` on your Shrine storage, or you're storing
  # files on the filesystem, make sure to subtract the appropriate part
  # from the path assigned to `:id`.
  def shrine_style_file(style)
    location = style.attachment.path(style.name)
    # if you're storing files on disk, make sure to subtract the absolute path
    location = location.sub(%r{^#{storage.prefix}/}, "") if storage.try(:prefix)
    location = location.sub(%r{^#{Shrine.storages[:store].directory}/}, "") if Shrine.storages[:store].respond_to?(:directory)

    Shrine.uploaded_file(
      storage:  :store,
      id:       location,
      metadata: {},
    )
  end

  def storage
    Shrine.storages[:store]
  end
end
