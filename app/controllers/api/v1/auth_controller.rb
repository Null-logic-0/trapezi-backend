class Api::V1::AuthController < ApplicationController
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception

  require "google-id-token"
  before_action :require_login, only: [ :destroy ]
  before_action :blocked?, except: [ :destroy ]

  def create
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      token = encode_token({ user_id: @user&.id })
      render json: { token: token, user: @user }, status: :ok
    else
      render json: { error: I18n.t("errors.invalid_credentials") }, status: :unauthorized

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

      first_name, *rest = full_name.split(" ")
      last_name = rest.join(" ").presence

      @user = User.find_or_initialize_by(email: email)
      @user&.google_uid = payload["sub"]

      @user.name ||= first_name
      @user.last_name ||= last_name

      @user.password ||= SecureRandom.hex(10)

      @user.is_admin ||= false
      @user.is_blocked ||= false
      @user.business_owner ||= false
      @user.moderator ||= false

      unless @user.save
        return render json: { error: formatted_errors(@user) }, status: :unprocessable_entity
      end

      if @user.is_blocked?
        render json: { error: I18n.t("activerecord.errors.errors.blocked_by_admin") }, status: :forbidden
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

  def password_reset_request
    user = User.find_by(email: params[:email].to_s.downcase)
    message = { message: I18n.t("mailer.reset_password.instruction_sent") }

    if user
      if user.google_uid.present?
        return render json: { error: I18n.t("activerecord.errors.errors.google_user_cannot_reset") }, status: :forbidden
      end

      if user.is_blocked?
        return render json: { error: I18n.t("activerecord.errors.errors.blocked_by_admin") }, status: :forbidden
      end

      signed_token = user.generate_password_reset_token!
      PasswordMailer.with(user: user, token: signed_token).reset_email.deliver_now
    end

    render json: message, status: :ok
  end

  def password_reset
    begin
      raw_token = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base, digest: "SHA256").verify(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      return render json: { error: "Invalid token." }, status: :unprocessable_entity
    end

    user = User.find_by(password_reset_token: raw_token)

    if user.nil? || !user.password_reset_token_valid?(10.minute)
      return render json: { error: I18n.t("activerecord.errors.errors.invalid_token") }, status: :unprocessable_entity
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      user.clear_password_reset_token!
      render json: { message: I18n.t("messages.password_updated") }, status: :ok
    else
      render json: { error: formatted_errors(user) }, status: :unprocessable_entity
    end
  end
end
