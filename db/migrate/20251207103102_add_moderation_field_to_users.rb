class AddModerationFieldToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :strike_count, :integer
  end
end
