class AddResourceToPayments < ActiveRecord::Migration[8.0]
  def change
    add_reference :payments, :resource, polymorphic: true, null: false
  end
end
