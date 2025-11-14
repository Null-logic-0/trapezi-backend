require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_mailer.default_url_options = { host: "trapezi.ge", protocol: "https" }
  Rails.application.routes.default_url_options = { host: "trapezi.ge", protocol: "https" }

  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.active_storage.service = :amazon

  config.assume_ssl = true
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"

  config.active_support.report_deprecations = false

  config.cache_store = :solid_cache_store

  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  config.action_mailer.default_url_options = {
    host: Rails.application.credentials.dig(:frontend_url),
    protocol: "https"
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: "resend",
    password: Rails.application.credentials.dig(:resend, :api_key),
    address: "resend.com",
    port: 587,
    authentication: :plain
  }

  config.i18n.fallbacks = true

  config.active_job.queue_adapter = :async

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]
end
