require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @admin = users(:admin)
  end

  test "should get index" do
    log_in_as(@admin)
    get api_v1_users_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should show user" do
    log_in_as(@admin)
    @user = User.find_by(name: "John")
    get api_v1_user_path(@user), headers: @auth_headers, as: :json
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

    assert_response :success
  end

  test "should confirm user creation" do
    post api_v1_confirm_path, params: {
      token: @user.generate_confirmation_token!,
      confirmed: true
    }
    assert_response :created
  end

  test "should update user profile" do
    log_in_as(@user)
    patch api_v1_update_profile_path, params: {
      name: "Peter"
    }, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should update user's password" do
    log_in_as(@user)
    patch api_v1_update_password_path, params: {
      current_password: "password1234",
      password: "password12345",
      password_confirmation: "password12345"

    }, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should delete profile" do
    log_in_as(@user)
    delete api_v1_delete_profile_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should update user" do
    log_in_as(@admin)
    @user = User.find_by(name: "John")
    patch api_v1_user_path(@user), params: {
      is_blocked: true
    }, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should destroy user" do
    log_in_as(@admin)
    @user = User.find_by(name: "John")
    delete api_v1_user_path(@user), headers: @auth_headers, as: :json
    assert_response :success
  end
end
