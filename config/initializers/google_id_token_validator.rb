require "google-id-token"
require "net/http"
require "uri"
require "json"

if Rails.env.development?
  GoogleIDToken::Validator.class_eval do
    def check_with_ssl_disabled(token, client_id)
      uri = URI("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{token}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # safe for dev only

      response = http.get(uri.request_uri)
      payload = JSON.parse(response.body)
      raise GoogleIDToken::ValidationError, "Invalid token" unless payload["aud"] == client_id

      payload
    end
  end
end
