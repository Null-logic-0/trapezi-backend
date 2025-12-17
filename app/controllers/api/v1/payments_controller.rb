class Api::V1::PaymentsController < ApplicationController
  skip_before_action :require_login, only: [ :callback ]
  before_action :require_login, only: [ :create ]

  def create
    requested_plan = params[:plan_type]

    plan_config = Payment::PLANS[requested_plan]
    unless plan_config
      return render json: { error: "Invalid plan selected" }, status: :bad_request
    end

    service = TbcPaymentsService.new
    frontend_success_url = ENV["FRONTEND_CHECKOUT_SUCCESS_URL"]
    backend_callback_url = ENV["BACKEND_CALLBACK_URL"]

    order_id = "ORD-#{Time.now.to_i}-#{SecureRandom.hex(4)}"

    Payment.create!(
      user: current_user,
      resource: current_user,
      order_id: order_id,
      amount: plan_config[:amount],
      plan_type: requested_plan,
      status: "pending"
    )

    begin
      checkout_url = service.create_order(
        order_id: order_id,
        amount: plan_config[:amount],
        description: "#{requested_plan.capitalize} Subscription",
        response_url: frontend_success_url,
        callback_url: backend_callback_url
      )

      render json: { checkout_url: checkout_url }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def callback
    payment_data = callback_params
    payment = Payment.find_by(order_id: payment_data["order_id"])
    return render json: { error: "Order not found" }, status: :not_found unless payment
    payment.update(status: payment_data["order_status"])

    user = payment.user

    if payment_data["order_status"] == "approved"
      user.activate_plan(user.plan)
      Rails.logger.info "User #{user.id} activated plan until #{user.plan_expires_at}"
    end

    render json: { status: "OK", plan: user.plan }
  end

  private

  def callback_params
    params.permit(:order_id, :order_status)
  end
end
