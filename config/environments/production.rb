require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Do not fall back to the asset pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Kamal's asset bridging (asset_path in config/deploy.yml) copies the previous
  # release's assets next to the new ones, manifest included. Sprockets names its
  # manifest randomly and, when it finds two, reads the first alphabetically,
  # which can be the old one: the new pages then get the old CSS and JS. With a
  # fixed name the new release's manifest wins (Kamal never overwrites it with
  # the old copy) and Sprockets reads it without searching.
  config.assets.manifest = Rails.root.join("public/assets/.sprockets-manifest.json").to_s

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # kamal-proxy terminates SSL (see `proxy` in config/deploy.yml).
  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # The app doesn't use Rails.cache for anything that needs to survive a restart.
  config.cache_store = :memory_store

  # Background jobs (deliver_later and the weekly recurring tasks in config/recurring.yml)
  # run on Solid Queue, inside Puma (SOLID_QUEUE_IN_PUMA, see config/deploy.yml).
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Emails. There is no sendmail inside the container, so deliver through an SMTP
  # relay (SendGrid by default). SMTP_PASSWORD comes from .kamal/secrets.
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "our-milheones.simaobelchior.net"),
    protocol: "https"
  }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "smtp.sendgrid.net"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    user_name: ENV.fetch("SMTP_USERNAME", "apikey"),
    password: ENV["SMTP_PASSWORD"],
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
