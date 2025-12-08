require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TrapeziBackend
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true
    config.eager_load_paths << Rails.root.join("app/services")

    # -------------------------
    # i18n configuration
    # -------------------------
    config.i18n.available_locales = [ :en, :ka ]
    config.i18n.default_locale = :ka
    config.i18n.enforce_available_locales = true
  end
end
