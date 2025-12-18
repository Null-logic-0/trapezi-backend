require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  Rails.application.routes.default_url_options = { host: "localhost", port: 3000 }

  config.enable_reloading = true

  config.eager_load = false

  config.consider_all_requests_local = true

  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  config.cache_store = :memory_store

  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: Rails.application.credentials.dig(:mailtrap, :username),
    password: Rails.application.credentials.dig(:mailtrap, :password),
    address: "smtp.mailtrap.io",
    domain: "localhost",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
    openssl_verify_mode: "none" # <--- ignore SSL cert errors
  }
  #
  # config.action_mailer.smtp_settings = {
  #   user_name: "resend",
  #   password: Rails.application.credentials.dig(:resend, :api_key),
  #   address: "resend.com",
  #   port: 587,
  #   authentication: :plain
  # }

  config.active_job.queue_adapter = :async

  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load

  config.active_record.verbose_query_logs = true

  config.active_record.query_log_tags_enabled = true

  config.active_job.verbose_enqueue_logs = true

  config.action_view.annotate_rendered_view_with_filenames = true

  config.action_controller.raise_on_missing_callback_actions = true
end
