class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show destroy update ]
  before_action :require_login, except: %i[ create ]
  before_action :admin?, only: %i[ index destroy update ]
  before_action :blocked?, except: %i[ index destroy update create ]

  def index
    @users = User.order(created_at: :desc)
    render json: @users.as_json, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show; end

  def profile
    @user = current_user
    render json: @user.as_json, status: :ok
  end

  def create
    @user = User.new(user_params)

    if @user&.save
      token = encode_token({ user_id: @user.id })
      render json: {
        user: @user.as_json(except: [ :password_digest ]),
        token: token
      }, status: :created
    else
      render json: { success: false, errors: formatted_errors(@user) }, status: :unprocessable_entity
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

  def admin_params
    params.permit(:moderator, :is_admin, :is_blocked, :business_owner)
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
