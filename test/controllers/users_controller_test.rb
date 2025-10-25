require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index" do
    log_in_as(@user)
    get api_v1_users_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should get current logged-in user" do
    log_in_as(@user)
    get api_v1_profile_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post api_v1_signup_path, params: {
        name: "john",
        last_name: "doe",
        email: "john@example.com",
        password: "password1234",
        password_confirmation: "password1234"
      }, as: :json
    end

    assert_response :created
  end
end
