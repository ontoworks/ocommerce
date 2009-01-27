class CreateAppliedDiscounts < ActiveRecord::Migration
  def self.up
    create_table :applied_discounts do |t|
      t.integer :order_id
      t.integer :string
      t.integer :discount_id
      t.float :price_off
      t.timestamps
    end
  end

  def self.down
    drop_table :applied_discounts
  end
end
