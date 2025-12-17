class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true

  PLANS = {
    "monthly" => { amount: 14.99, duration: 1.month },
    "yearly" => { amount: 149.99, duration: 1.year },
    "2_days" => { amount: 5.00, duration: 2.days },
    "2_weeks" => { amount: 10.00, duration: 2.weeks },
    "1_month" => { amount: 15.00, duration: 1.month },
    "1_minute" => { price: 2.00, duration: 1.minute } # Testing purpose only

  }.freeze

  validates :plan_type, inclusion: { in: PLANS.keys }
end
