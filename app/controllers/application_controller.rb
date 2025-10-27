class ApplicationController < ActionController::API
  require "jwt"

  before_action :require_login
  helper_method :current_user, :encode_token, :decode_token

  private

  def current_user
    return @current_user if @current_user

    header = request.headers["Authorization"]
    return nil unless header

    token = header.split(" ").last
    decoded = decode_token(token)
    return nil unless decoded

    @current_user = User.find_by(id: decoded[:user_id])
  rescue
    nil
  end

  def current_user?(user)
    current_user == user
  end

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue
    nil
  end

  def encode_token(payload)
    payload[:exp] = 30.days.from_now.to_i
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def require_login
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.blank? || BlacklistedToken.exists?(token: token)
      render json: { error: "Unauthorized" }, status: :unauthorized
    else
      @current_user = User.find(decode_token(token)["user_id"])
    end
  end

  def admin?
    unless current_user&.is_admin?
      render json: { error: "Admins only" }, status: :forbidden
    end
  end

  def blocked?
    @user = User.find_by(email: params[:email])

    if @user&.is_blocked?
      render json: { error: "Your account has been blocked by admin!" }, status: :forbidden
    end
  end
end
