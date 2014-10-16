class FogFactory
  def initialize(credentials = {})
    Fog.mock!

    @credentials = credentials
  end

  def self.fog_config
    OpenStruct.new(:credentials => { 
                     :provider => 'AWS',
                     :aws_access_key_id => 'XXX',
                     :aws_secret_access_key => 'YYY'
                   },
                   :bucket => 'af-mock-bucket')
  end

  def fog
    @fog ||= Fog::Storage.new(self.class.fog_config.credentials)
  end

  def bucket
    fog.directories.get(self.class.fog_config.bucket) || fog.directories.create(:key => self.class.fog_config.bucket)
  end

  def create_png_file(options = {})
    file = bucket.files.new

    file.key = options[:key] || "#{SecureRandom.uuid}.png"
    file.content_length = Random.rand(10..50000)
    file.content_type = options[:content_type] || "image/png"
    file.last_modified = options[:last_modified] || 1.minute.ago
    file.public = true

    file.save

    file
  end
end
