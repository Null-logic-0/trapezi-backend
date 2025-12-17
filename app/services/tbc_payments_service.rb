class TbcPaymentsService
  require "digest"
  require "json"
  require "faraday"

  BASE_URL = ENV["TBC_BASE_URL"]

  def initialize
    @merchant_id = ENV["TBC_MERCHANT_ID"].to_s.strip.to_i
    @secret_key = ENV["TBC_SECRET_KEY"].to_s.strip
  end

  def create_order(order_id:, amount:, currency: "GEL", description:, response_url:, callback_url:)
    raw_params = {
      order_id: order_id.to_s,
      merchant_id: @merchant_id,
      order_desc: description,
      currency: currency,
      amount: (amount * 100).to_i,
      response_url: response_url,
      server_callback_url: callback_url
    }
    params = raw_params.reject { |_, v| v.nil? || v.to_s.empty? }

    params[:signature] = generate_signature(params)

    conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post("checkout/url") do |req|
      req.body = { request: params }
    end

    if response.success? && response.body.dig("response", "response_status") == "success"
      response.body.dig("response", "checkout_url")
    else
      Rails.logger.error("TBC Request: #{params}")
      Rails.logger.error("TBC Response: #{response.body}")

      error_msg = response.body.dig("response", "error_message") || "Unknown Error"
      raise StandardError, "TBC API Error: #{error_msg}"
    end
  end

  def verify_signature?(params)
    received_signature = params["signature"]
    return false unless received_signature
    calc_params = params.except("signature", "response_signature_string", "controller", "action")
    generate_signature(calc_params) == received_signature
  end

  private

  def generate_signature(params)
    string_params = params.transform_keys(&:to_s)

    sorted_params = string_params.sort_by { |k, _v| k }

    values = sorted_params.map { |_k, v| v.to_s }

    values.unshift(@secret_key)

    sign_string = values.join("|")

    Digest::SHA1.hexdigest(sign_string)
  end
end
