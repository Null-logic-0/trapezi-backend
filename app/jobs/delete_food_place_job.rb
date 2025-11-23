class DeleteFoodPlaceJob < ApplicationJob
  queue_as :default

  def perform(food_place_id)
    food_place = FoodPlace.find_by(id: food_place_id)
    return unless food_place

    food_place.destroy
  end
end
