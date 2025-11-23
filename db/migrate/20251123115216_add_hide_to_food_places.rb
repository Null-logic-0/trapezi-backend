class AddHideToFoodPlaces < ActiveRecord::Migration[8.0]
  def change
    add_column :food_places, :hidden, :boolean
  end
end
