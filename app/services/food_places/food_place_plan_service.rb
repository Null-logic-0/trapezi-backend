module FoodPlaces
  class FoodPlacePlanService
    PLANS = {
      "2_days" => { price: 5, duration: 2.days },
      "2_weeks" => { price: 10, duration: 2.weeks },
      "1_month" => { price: 15, duration: 1.month },
      "1_minute" => { price: 2, duration: 1.minute } # Testing purpose only
    }.freeze
  end
end
