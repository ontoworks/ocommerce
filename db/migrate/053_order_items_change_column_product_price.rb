class OrderItemsChangeColumnProductPrice < ActiveRecord::Migration
  def self.up
    change_column :order_items, :product_price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
  end
end
