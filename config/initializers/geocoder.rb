require "redis"

Geocoder.configure(
  lookup: :google,
  api_key: Rails.application.credentials.dig(:google, :maps_api_key),
  timeout: 5,
  units: :km
)
