require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

HOCOMOCO_VERSION_NUMBER = 14
HOCOMOCO_VERSION = "hocomoco#{HOCOMOCO_VERSION_NUMBER}"

module HocomocoSite
  class Application < Rails::Application
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'env.yaml')
      next  unless File.exists?(env_file)
      YAML.load_file(env_file).each{|k,v| ENV[k] ||= v }
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.i18n.fallbacks = [I18n.default_locale]

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
