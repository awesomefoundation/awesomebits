if %w(development test cucumber performance).include?(Rails.env)
  s3_decision = {}
else
  s3_decision = {
    storage:         :fog,
    path:            ":class/:attachment/:id/:style/:filename",
    fog_credentials: {
      aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      provider:              'AWS',
      region:                'us-west-1'
    },
    fog_directory:   ENV['AWS_BUCKET'] || "afdev-#{Rails.env}",
    fog_public:      :public
  }
end

Paperclip::Attachment.default_options.merge!(s3_decision)
Paperclip.options[:command_path] = ["/usr/local/bin", "/usr/bin"]
