require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/memory"
require "shrine/storage/s3"
require "uppy/s3_multipart"

unless ENV['AWS_BUCKET']
  require "shrine/storage/tus"
end

Shrine.plugin :instrumentation
Shrine.logger = Rails.logger

if Rails.env.test?
  s3_options = {
    bucket: "af-mock",
    region: "us-east-1",
    stub_responses: true
  }

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new,
    s3_cache: Shrine::Storage::S3.new(prefix: "uploads", **s3_options),
    s3_store: Shrine::Storage::S3.new(public: true, **s3_options),
    tus: Shrine::Storage::Tus.new
  }

elsif Rails.env.development? && !ENV["AWS_BUCKET"]
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "system/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "system"),
    tus: Shrine::Storage::Tus.new
  }

else
  s3_options = {
    bucket: ENV["AWS_BUCKET"],
    region: ENV["AWS_REGION"] || "us-east-1",
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
  }
  
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "uploads", **s3_options),
    store: Shrine::Storage::S3.new(public: true, **s3_options),
  }
end

Shrine.plugin :uppy_s3_multipart
