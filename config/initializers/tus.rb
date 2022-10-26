require "tus/server"
require "tus/storage/filesystem"

if Rails.env.test?
  Tus::Server.opts[:storage] = Tus::Storage::Filesystem.new("tmp/tus-test")
else
  Tus::Server.opts[:storage] = Tus::Storage::Filesystem.new("tmp/tus")
end
