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
