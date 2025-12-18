require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_place = food_places(:one)
    @user = users(:one)
    @admin = users(:admin)
    @report = reports(:one)
  end

  test "should get reports" do
    log_in_as(@admin)
    get api_v1_reports_path(@food_place), headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should show report" do
    log_in_as(@admin)
    get api_v1_report_path(@food_place), headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should create report" do
    log_in_as(@user)
    post api_v1_create_report_path(@food_place), params: {
      title: "Report Title",
      description: "Report Description"
    }, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should update report status" do
    log_in_as(@admin)
    patch api_v1_update_report_path(@food_place, @report), params: {
      status: 1
    }, headers: @auth_headers, as: :json
    assert_response :success
  end

  test "should destroy report" do
    log_in_as(@admin)
    delete api_v1_destroy_report_path(@food_place, @report), headers: @auth_headers, as: :json
    assert_response :ok
  end
end
