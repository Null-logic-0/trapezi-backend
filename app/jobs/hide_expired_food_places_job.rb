class HideExpiredFoodPlacesJob < ApplicationJob
  queue_as :default

  def perform
    FoodPlace.joins(:user)
             .where(users: { plan: "pro" })
             .where("created_at <= ?", 1.month.ago)
             .update_all(hidden: true)
  end
end
