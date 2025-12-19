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
    config.active_job.queue_adapter = :sidekiq

    config.time_zone = "Tbilisi"
    config.active_record.default_timezone = :local

    # -------------------------
    # i18n configuration
    # -------------------------
    config.i18n.available_locales = [ :en, :ka ]
    config.i18n.default_locale = :ka
    config.i18n.enforce_available_locales = true

    config.hosts << /.*\.ngrok-free\.app/
  end
end
