require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @payment = payments(:one)
  end

  test "should checkout payment" do
    log_in_as(@user)
    post api_v1_create_payment_path,
         params: { plan_type: "monthly" },
         headers: @auth_headers,
         as: :json
    assert_response :success
  end

  test "payment callback" do
    post api_v1_payment_callback_path, params: {
      "order_id": @payment.order_id,
      "order_status": "approved"
    }, as: :json
    assert_response :success
  end
end
