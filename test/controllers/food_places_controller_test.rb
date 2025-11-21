require "test_helper"

class FoodPlacesControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @food_place = food_places(:one)
    @review = reviews(:one)
    @user = users(:one)
    @admin = users(:admin)
  end

  test "should get index" do
    get api_v1_food_places_path, as: :json
    assert_response :success
  end

  test "should show food_place" do
    log_in_as(@user)
    get api_v1_food_place_path(@food_place), headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should show current_user food_places" do
    log_in_as(@user)
    get api_v1_my_businesses_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should create food_place" do
    log_in_as(@user)
    post api_v1_food_places_path,
         params: {
           business_name: "Trapezi Cafe",
           description: "A cozy modern cafe serving organic pastries and coffee in the heart of Tbilisi.",
           categories: %w[cafe bar],
           phone: "+995555377505",
           address: "Rustaveli Ave 15 Tbilisi, Georgia",
           menu_pdf: fixture_file_upload("sample.pdf", "application/pdf"),
           images: [
             fixture_file_upload("image1.jpg", "image/jpg")
           ]

         },
         headers: @auth_headers

    assert_response :created
  end

  test "should update food_place" do
    log_in_as(@user)
    patch api_v1_food_place_path(@food_place), params: {
      business_name: "Trapez Cafe"

    }, headers: @auth_headers, as: :json

    assert_equal "Trapez Cafe", @food_place.business_name
  end

  test "should destroy food_place" do
    log_in_as(@user)

    delete api_v1_food_place_path(@food_place), headers: @auth_headers, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Deleted successfully!", json_response["message"]

    assert_raises(ActiveRecord::RecordNotFound) { @food_place.reload }
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

  test "should delete food places by admin" do
    log_in_as(@admin)
    delete api_v1_destroy_by_admin_path(@food_place), headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should get all food_places by admin" do
    log_in_as(@admin)
    get api_v1_all_places_path, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should update vip by admin" do
    log_in_as(@admin)
    @food_place = FoodPlace.find_by(business_name: "Trapez Cafe")
    patch api_v1_update_vip_path(@food_place), params: {
      is_vip: true
    }, headers: @auth_headers, as: :json
    assert_response :success
  end
end
