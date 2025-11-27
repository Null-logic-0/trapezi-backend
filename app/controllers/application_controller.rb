class ApplicationController < ActionController::API
  require "jwt"

  before_action :set_locale
  before_action :require_login
  before_action :check_maintenance_mode

  helper_method :current_user,
                :encode_token,
                :decode_token,
                :formatted_errors,
                :filtered_places

  private

  def check_maintenance_mode
    return unless AppSetting.maintenance_mode?

    return if current_user&.is_admin?

    return if request.path.include?("/login") ||
              request.path.include?("/logout") ||
              request.path.include?("/blog") ||
              request.path.include?("/admin/maintenance") ||
              request.path.include?("/admin/registration") ||
              request.path.include?("/video_tutorials")

    render json: {
      error: I18n.t("errors.maintenance_mode_active")
    }, status: :service_unavailable
  end

  def set_locale
    locale = request.headers["Accept-Language"]&.slice(0, 2)&.to_sym
    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def formatted_errors(record)
    record.errors.messages.transform_values { |msgs| msgs.map(&:to_s) }
  end

  def extract_locale_from_header
    header = request.headers["Accept-Language"]
    return nil unless header.present?
    header.split(",").first&.slice(0, 2)
  end

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

  def moderator?
    unless current_user&.is_admin? || current_user&.moderator?
      render json: { error: "Admins or moderators only" }, status: :forbidden
    end
  end

  def blocked?
    @user = User.find_by(email: params[:email])

    if @user&.is_blocked?
      render json: { error: "Your account has been blocked by admin!" }, status: :forbidden
    end
  end

  def filtered_places(scope)
    if params[:categories].present?
      categories = params[:categories].split(",").map(&:strip).map(&:downcase)
      scope = scope.where("categories && ARRAY[?]::varchar[]", categories)
    end
    if params[:plan].present?
      scope = case params[:plan].downcase
      when "vip" then scope.vip
      when "free" then scope.free
      else scope
      end
    end
    scope
  end
end
