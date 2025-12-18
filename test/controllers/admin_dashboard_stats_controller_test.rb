require "test_helper"

class AdminDashboardStatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
  end

  test "should get admin dashboard stats" do
    log_in_as(@user)
    get api_v1_dashboard_path, headers: @auth_headers
    assert_response :success
  end
end
