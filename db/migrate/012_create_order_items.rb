class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.integer :order_id
      t.integer :product_id
      t.string :product_name
      t.string :product_model
      t.string :product_price
      t.string :final_price
      t.string :quantity
      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
