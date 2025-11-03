class CreateFoodPlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :food_places do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.text :description
      t.string :category
      t.string :address
      t.float :latitude
      t.float :longitude
      t.jsonb :working_schedule, default: {}
      t.string :website
      t.string :facebook
      t.string :instagram
      t.string :tiktok

      t.timestamps
    end
  end
end
