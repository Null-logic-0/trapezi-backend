class Api::V1::UsersController < ApplicationController
  include Pagination

  before_action :set_user, only: %i[ show destroy update ]
  before_action :require_login, except: %i[ create confirm ]
  before_action :admin?, only: %i[ index destroy update create_by_admin ]
  before_action :blocked?, except: %i[ index destroy update create ]

  def index
    scope = filtered_users(User.where.not(id: current_user&.id)
                               .order(created_at: :desc)
                               .search(params[:search]))

    result = paginate(scope)

    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show; end

  def profile
    @user = current_user
    render json: @user.as_json, status: :ok
  end

  def create
    result = User::UserRegistrationService.call(user_params)

    if result[:success]
      render json: { success: true, message: result[:message] }, status: :ok
    else
      render json: { success: false, errors: result[:errors] || result[:error] }, status: :unprocessable_entity
    end
  end

  def confirm
    result = User::UserConfirmationService.call(params[:token])

    if result[:success]
      render json: { user: result[:user], token: result[:token], message: result[:message] }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def create_by_admin
    result = User::AdminUserCreationService.call(user_params)
    if result[:success]
      render json: { user: result[:user] }, status: :created
    else
      render json: { success: false, errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def update_profile
    @user = current_user
    if profile_params[:avatar].present?
      @user&.avatar&.attach(profile_params[:avatar])
    end
    if @user&.update(profile_params.except(:current_password, :password, :password_confirmation))
      render json: @user.as_json, status: :ok
    else
      render json: { success: false, errors: @user&.errors&.full_messages }, status: :unprocessable_entity
    end
  end

  def update_password
    @user = current_user
    unless password_params[:current_password].present?
      return render json: { success: false, errors: { current_password: I18n.t("activerecord.errors.models.user.attributes.current_password.blank") } }, status: :unprocessable_entity
    end

    unless @user&.authenticate(password_params[:current_password])
      return render json: { success: false, errors: { current_password: I18n.t("activerecord.errors.models.user.attributes.current_password.invalid") } }, status: :unauthorized
    end

    if @user&.google_uid.present?
      return render json: { error: I18n.t("activerecord.errors.errors.google_user_cannot_reset") }, status: :forbidden
    end

    if @user&.authenticate(password_params[:current_password])
      if @user&.update(password_params.slice(:password, :password_confirmation))
        render json: @user.as_json, status: :ok
      else
        render json: { success: false, errors: formatted_errors(@user) }, status: :unprocessable_entity
      end
    end
  end

  def update
    if @user&.update(admin_params)
      render json: @user.as_json, status: :ok
    else
      render json: { success: false, errors: @user&.errors }, status: :unprocessable_entity
    end
  end

  def delete_profile
    @user = current_user
    if @user&.destroy
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: @user&.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user&.destroy
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: @user&.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def filtered_users(scope)
    # Role filter
    if params[:role].present?
      scope = case params[:role].downcase
      when "admin" then scope.admin
      when "moderator" then scope.moderator
      when "owner" then scope.owner
      when "user" then scope.user
      else scope
      end
    end

    # Status filter
    if params[:status].present?
      scope = case params[:status].downcase
      when "blocked" then scope.blocked
      when "active" then scope.active
      else scope
      end
    end

    scope
  end

  def admin_params
    params.permit(:moderator, :is_admin, :is_blocked)
  end

  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end

  def profile_params
    params.permit(:name, :last_name, :avatar, :business_owner)
  end

  def user_params
    params.permit(
      :name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      :business_owner)
  end
end
