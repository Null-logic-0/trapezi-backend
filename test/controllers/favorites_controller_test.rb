require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_place = food_places(:one)
    @user = users(:one)
    @admin = users(:admin)
  end

  test "should get favorite food_places" do
    log_in_as(@user)

    get api_v1_favorites_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should toggle favorite food_place" do
    log_in_as(@user)
    post api_v1_favorite_path(@food_place), headers: @auth_headers, as: :json
    assert_response :success
  end
end
