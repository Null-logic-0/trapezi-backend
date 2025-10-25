class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.boolean :is_admin, default: false
      t.boolean :business_owner, default: false
      t.boolean :moderator, default: false
      t.boolean :is_blocked, default: false

      t.timestamps
    end
  end
end
