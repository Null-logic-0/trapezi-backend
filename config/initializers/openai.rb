require "openai"

OpenAIClient = OpenAI::Client.new(
  access_token: Rails.application.credentials.dig(:openai, :api_key)
)
