class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :user_id
      t.string :delivery_name
      t.string :delivery_company
      t.string :delivery_street_address
      t.string :delivery_suburb
      t.string :delivery_city
      t.string :delivery_postcode
      t.string :delivery_state
      t.string :delivery_country
      t.string :billing_name
      t.string :billing_company
      t.string :billing_street_address
      t.string :billing_suburb
      t.string :billing_city
      t.string :billing_postcode
      t.string :billing_state
      t.string :billing_country
      t.string :payment_method
      t.string :shipping_method
      t.string :cc_type
      t.string :cc_owner
      t.string :cc_number
      t.string :cc_expires
      t.string :cvvnumber
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
