class AddPlanToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :plan, :string, default: "free"
    add_column :users, :plan_expires_at, :datetime
  end
end
