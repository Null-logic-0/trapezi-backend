class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food_place, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :status, default: 0
      t.string :report_code

      t.timestamps
    end
  end
end
