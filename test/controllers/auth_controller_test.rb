require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @admin = users(:admin)
    @password = "password1234"
  end

  test "should login successfully with valid credentials" do
    post api_v1_login_path, params: { email: @user.email, password: @password }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["token"].present?, "Token should be present"
    assert_equal @user.email, json_response["user"]["email"]
  end

  test "should fail login with invalid credentials" do
    post api_v1_login_path, params: { email: @user.email, password: "wrongPassword" }, as: :json
    assert_response :unauthorized

    json_response = JSON.parse(response.body)
    assert_equal I18n.t("errors.invalid_credentials"), json_response["error"]
  end

  test "should logout successfully with valid credentials" do
    post api_v1_login_path, params: { email: @user.email, password: @password }, as: :json
    token = JSON.parse(response.body)["token"]
    assert token.present?, "Token should be present after login"

    delete api_v1_logout_path, headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Logged out successfully", json_response["message"]

    assert BlacklistedToken.exists?(token: token), "Token should be in blacklist"

    get api_v1_users_path, headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["error"]
  end

  test "should send email for password reset" do
    post api_v1_password_reset_request_path, params: { email: @user.email }
    assert_response :success
  end

  test "should reset password" do
    post api_v1_password_reset_path, params: {
      token: @user.generate_password_reset_token!,
      password: "newPassword1234",
      password_confirmation: "newPassword1234"
    }
    assert_response :success
  end

  test "should login as admin" do
    post api_v1_login_as_admin_path, params: { email: @admin.email, password: @password }, as: :json
    assert_response :success
  end

  test "should fail login as admin" do
    post api_v1_login_as_admin_path, params: { email: @user.email, password: @password }, as: :json
    assert_response :forbidden
  end
end
