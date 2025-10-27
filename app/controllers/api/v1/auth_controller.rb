class Api::V1::AuthController < ApplicationController
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception

  require "google-id-token"
  before_action :require_login, except: [ :create, :google_oauth ]
  before_action :blocked?, except: [ :destroy ]

  def create
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      token = encode_token({ user_id: @user&.id })
      render json: { token: token, user: @user }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def google_oauth
    credential = params[:credential]

    unless credential.is_a?(String)
      return render json: { error: "Invalid credential format" }, status: :bad_request
    end

    begin
      validator = GoogleIDToken::Validator.new

      payload = if Rails.env.development?
                  validator.check_with_ssl_disabled(credential, ENV["GOOGLE_CLIENT_ID"])
      else
                  validator.check(credential, ENV["GOOGLE_CLIENT_ID"])
      end

      email = payload["email"]
      full_name = payload["name"]
      picture = payload["avatar"]

      first_name, *rest = full_name.split(" ")
      last_name = rest.join(" ").presence

      @user = User.find_or_initialize_by(email: email)
      @user.name ||= first_name
      @user.last_name ||= last_name
      @user.avatar ||= picture
      @user.password ||= SecureRandom.hex(10)

      @user.is_admin ||= false
      @user.is_blocked ||= false
      @user.business_owner ||= false
      @user.moderator ||= false

      unless @user.save
        return render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
      end

      if @user.is_blocked?
        render json: { error: "Your account has been blocked by admin!" }, status: :forbidden
        return
      end

      token = encode_token({ user_id: @user.id })

      cookies.signed[:jwt] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :none
      }

      render json: { token: token, user: @user }, status: :ok

    rescue GoogleIDToken::ValidationError => e
      render json: { error: "Invalid Google token: #{e.message}" }, status: :unauthorized
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record&.errors&.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    token = request.headers["Authorization"]&.split(" ")&.last
    if token
      BlacklistedToken.create!(token: token, expires_at: Time.at(decode_token(token)["exp"]))
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { error: "No token provided" }, status: :bad_request
    end
  end
end
