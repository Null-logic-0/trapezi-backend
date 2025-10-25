require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
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
    assert_equal "Invalid email or password", json_response["error"]
  end
end
