module FoodPlaces
  class VipPaymentService
    def initialize(user:, food_place:, vip_plan: nil)
      @user = user
      @food_place = food_place
      @vip_plan = vip_plan.presence
    end

    def call
      plan_key = @vip_plan.to_s
      plan = FoodPlacePlanService::PLANS[plan_key]

      order_id = generate_order_id

      begin
        Payment.create!(
          user: @user,
          order_id: order_id,
          amount: plan[:price],
          plan_type: plan_key,
          status: "pending",
          resource: @food_place

        )
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Payment creation failed: #{e.record&.errors&.full_messages&.join(', ')}"
        raise StandardError, "Payment creation failed: #{e.record&.errors&.full_messages&.join(', ')}"
      end

      @food_place.update!(
        vip_plan: plan_key,
        is_vip: true,
        vip_expires_at: Time.current + plan[:duration]
      )

      create_checkout(order_id, plan)
    end

    private

    def generate_order_id
      "VIP-#{Time.current.to_i}-#{SecureRandom.hex(4)}"
    end

    def create_checkout(order_id, plan)
      TbcPaymentsService.new.create_order(
        order_id: order_id,
        amount: plan[:price],
        description: "VIP Activation",
        response_url: ENV["FRONTEND_CHECKOUT_SUCCESS_URL"],
        callback_url: ENV["BACKEND_CALLBACK_URL"]
      )
    end
  end
end
