class Api::V1::FoodPlaceVipPaymentsController < ApplicationController
  before_action :require_login, except: [ :callback ]

  def callback
    data = callback_params

    payment = Payment.find_by(order_id: data["order_id"])
    return render json: { error: "Not found" }, status: :not_found unless payment

    payment.update!(status: data["order_status"])

    return render json: { status: "IGNORED" } unless data["order_status"] == "approved"

    plan = FoodPlaces::FoodPlacePlanService::PLANS[payment.plan_type]
    return render json: { error: "Plan not found" }, status: :unprocessable_entity unless plan

    payment.resource.activate_vip!(plan[:duration])

    Rails.logger.info(
      "FoodPlace #{payment.resource.id} VIP active until #{payment.resource.vip_expires_at}"
    )

    render json: { status: "OK" }
  end

  private

  def callback_params
    params.require(:response).permit(:order_id, :order_status)
  end
end
