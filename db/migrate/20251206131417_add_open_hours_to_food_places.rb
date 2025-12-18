class AddOpenHoursToFoodPlaces < ActiveRecord::Migration[8.0]
  def change
    add_column :food_places, :is_open, :boolean, default: false, null: false
  end
end
