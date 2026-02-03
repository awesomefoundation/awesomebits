require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Awesomefoundation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks templates))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |generate|
      generate.test_framework :rspec
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << Rails.root.join('app', 'extras')
    config.autoload_paths << Rails.root.join('app', 'models','callbacks')

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
