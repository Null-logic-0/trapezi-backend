module User::UserStatus
  extend ActiveSupport::Concern

  included do
    enum :plan, {
      free: "free",
      pro: "pro"
    }

    validates :plan, inclusion: { in: plans.keys }
  end

  def free_plan?
    plan == "free"
  end

  def paid_plan?
    plan == "pro"
  end

  def activate_plan(plan_type)
    duration = case plan_type
    when "monthly" then 1.month
    when "yearly" then 1.year
    else 1.month
    end

    start_date = plan_expires_at && plan_expires_at > Time.current ? plan_expires_at : Time.current

    transaction do
      update!(
        plan: "pro",
        plan_expires_at: start_date + duration
      )

      food_places.update_all(hidden: false)
    end
  end

  def activate_plan_for_testing
    update!(
      plan: "pro",
      plan_expires_at: Time.current + 1.minute
    )
  end

  def downgrade_expired_plan
    return if plan == "free"
    return if plan_expires_at.nil?
    return if plan_expires_at > Time.current

    transaction do
      update!(plan: "free", plan_expires_at: nil)
      enforce_free_plan_food_place_visibility!
    end
  end

  def enforce_free_plan_food_place_visibility!
    return unless plan == "free"

    visible_places = food_places.where(hidden: false).order(:created_at)

    visible_places.offset(1).update_all(hidden: true)
  end

  def add_strike!
    update!(strike_count: (strike_count || 0) + 1)
    block_if_limit_reached
  end

  def block_if_limit_reached
    block! if strike_count >= 2
  end

  def block!
    update!(is_blocked: true)
  end
end
