Rails.configuration.fog = 
  OpenStruct.new(
                 :credentials => {
                   :provider => 'AWS',
                   :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                   :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                 },

                 :bucket => ENV['AWS_BUCKET']
                 )
