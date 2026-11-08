ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Keep test uploads out of public/ and skip image processing (no ImageMagick needed).
CarrierWave.configure do |config|
  config.root = Rails.root.join("tmp/test_uploads")
  config.enable_processing = false
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end
