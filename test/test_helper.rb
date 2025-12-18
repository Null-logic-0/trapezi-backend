ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def encode_token(payload)
      JWT.encode(payload, Rails.application.secret_key_base)
    end

    Rails.application.routes.default_url_options[:host] = "http://localhost:3000/"

    def log_in_as(user)
      token = encode_token({ user_id: user.id })
      @auth_headers = { "Authorization" => "Bearer #{token}" }
    end
  end
end
