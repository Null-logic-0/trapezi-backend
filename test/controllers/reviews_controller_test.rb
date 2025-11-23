require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_place = food_places(:one)
    @review = reviews(:one)
    @user = users(:one)
    @admin = users(:admin)
  end

  test "should get review food_places" do
    log_in_as(@user)

    get api_v1_reviews_path(@food_place), headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should create review food_place" do
    log_in_as(@user)

    post api_v1_create_review_path(@food_place), params: {
      comment: "Lorem ipsum",
      rating: 5
    }, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should update review food_place" do
    log_in_as(@user)

    patch api_v1_update_review_path(@food_place, @review), params: {
      comment: "MyComment"
    }, headers: @auth_headers, as: :json
    assert_equal "MyComment", @review.comment
  end

  test "should destroy review for food_place" do
    log_in_as(@user)

    delete api_v1_delete_review_path(@food_place, @review),
           headers: @auth_headers,
           as: :json

    json_response = JSON.parse(response.body)
    assert_equal "Review deleted successfully", json_response["message"]
    assert_raises(ActiveRecord::RecordNotFound) { @review.reload }
    assert_response :ok
  end
end
