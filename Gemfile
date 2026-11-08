source "https://rubygems.org"

gem "rails", "~> 8.1.4", ">= 8.1.4.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Database-backed Active Job adapter; also runs the weekly recurring tasks (config/recurring.yml)
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Asset pipeline. The front end is Bootstrap 3 + jQuery + select2, so we keep Sprockets
# and compile the few .scss files with Dart Sass (no Node.js or libsass needed).
gem "sprockets-rails"
gem "dartsass-sprockets"
gem "jquery-rails"
# Stay on select2 3.x: the bet pickers rely on its "tags on a text input" API (removed in 4.x)
gem "select2-rails", "~> 3.5"

gem "devise", "~> 5.0"
gem "enumerate_it"
gem "kaminari"
gem "bootstrap-kaminari-views"
gem "carrierwave", "~> 3.1"
gem "mini_magick"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "letter_opener"
  # Successor of the annotate gem: `bundle exec annotaterb models`
  gem "annotaterb"
end

group :test do
  # Provides `assigns` and `assert_template` for the controller tests
  gem "rails-controller-testing"
end
