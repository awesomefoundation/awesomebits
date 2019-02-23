# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
# In environments other than test or development, the secret must be set
# in the SECRET_KEY_BASE environment variable.
Awesomefoundation::Application.config.secret_key_base = (Rails.env.development? || Rails.env.test?) ?  "insecure_token_just_for_test_and_dev" : ENV.fetch('SECRET_KEY_BASE')

# TODO https://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#action-pack
# Remove this and uncomment secret_key_base above
# In environments other than test or development, the secret must be set
# in the SECRET_TOKEN environment variable.
Awesomefoundation::Application.config.secret_token = (Rails.env.development? || Rails.env.test?) ?  "insecure_token_just_for_test_and_dev" : ENV.fetch('SECRET_TOKEN')
