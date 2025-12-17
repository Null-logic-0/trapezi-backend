class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.string :order_id
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.string :plan_type

      t.timestamps
    end
    add_index :payments, :order_id
  end
end
