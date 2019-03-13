require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Awesomefoundation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |generate|
      generate.test_framework :rspec
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += [
                              Rails.root.join('app', 'extras'),
                              Rails.root.join('app', 'models','callbacks')
                             ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Add to assets path
    config.assets.paths << Rails.root.join("vendor", "assets", "colorbox")

    # Use our own app as the handler for errors.
    config.exceptions_app = self.routes

    # Do not initialize on assets compilation
    config.assets.initialize_on_precompile = false

    # Load middleware
    config.middleware.use Rack::Attack

    # https://github.com/tobmatth/rack-ssl-enforcer
    # Only force SSL for www since we don't have a wildcard SSL cert
    # Do not enable HSTS yet
    if ENV['FORCE_HTTPS']
      config.middleware.insert_before ActionDispatch::Cookies, Rack::SslEnforcer, :only_hosts => /^(www)\./, :hsts => false
    end

    if ENV['SITE_PASSWORD'].present?
      config.middleware.use Rack::Auth::Basic do |username, password|
        username == ENV['SITE_PASSWORD'] && password == ENV['SITE_PASSWORD']
      end
    end
  end
end
