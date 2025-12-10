module User::UserStatus
  extend ActiveSupport::Concern

  included do
    enum :plan, {
      free: "free",
      pro: "pro"
    }, default: "free"

    validates :plan, inclusion: { in: plans.keys }
  end

  def free_plan?
    plan == "free"
  end

  def paid_plan?
    plan == "pro"
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
