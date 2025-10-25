class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]
  before_action :require_login, except: %i[ create ]

  # GET /users
  # GET /users.json
  def index
    @users = User.order(created_at: :desc)
    render json: @users.as_json, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  def profile
    @user = current_user
    render json: @user.as_json, status: :ok
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      token = encode_token({ user_id: @user.id })
      render json: {
        user: @user.as_json(except: [ :password_digest ]),
        token: token
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      render :show, status: :ok, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
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
