class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food_place, null: false, foreign_key: true
      t.string :comment
      t.integer :rating

      t.timestamps
    end
  end
end
