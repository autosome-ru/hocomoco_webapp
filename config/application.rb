require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

HOCOMOCO_VERSION_NUMBER = 13
HOCOMOCO_VERSION = "hocomoco#{HOCOMOCO_VERSION_NUMBER}"

module HocomocoSite
  class Application < Rails::Application
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'env.yaml')
      next  unless File.exists?(env_file)
      YAML.load_file(env_file).each{|k,v| ENV[k] ||= v }
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.action_dispatch.default_headers['Access-Control-Allow-Origin'] = '*'
    # config.action_dispatch.default_headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    # config.action_dispatch.default_headers['Access-Control-Request-Method'] = '*'
    # config.action_dispatch.default_headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    config.i18n.fallbacks = [I18n.default_locale]
  end
end
