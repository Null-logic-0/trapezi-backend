class Api::V1::AuthController < ApplicationController
  before_action :require_login, except: [ :create ]

  def create
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      token = encode_token({ user_id: @user&.id })
      render json: { token: token, user: @user }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
