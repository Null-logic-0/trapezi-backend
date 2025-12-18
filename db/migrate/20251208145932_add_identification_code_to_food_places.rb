class AddIdentificationCodeToFoodPlaces < ActiveRecord::Migration[8.0]
  def change
    add_column :food_places, :identification_code, :string
  end
end
