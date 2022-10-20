module FakeData
  module_function

  def fixture_file(filename)
    File.open(Rails.root.join("spec", "support", "fixtures", filename), binmode: true)
  end

  def shrine_uploaded_file(filename, storage: :store)
    file = fixture_file(filename)
    mime_type = Rack::Mime.mime_type(File.extname(filename))

    uploaded_file = Shrine.upload(file, storage, metadata: false)
    uploaded_file.metadata.merge!(
      "size" => File.size(file.path),
      "mime_type" => Rack::Mime.mime_type(File.extname(filename)),
      "filename" => filename
    )

    uploaded_file
  end
end
