class AddVipPlanToFoodPlaces < ActiveRecord::Migration[8.0]
  def change
    add_column :food_places, :vip_plan, :string
  end
end
