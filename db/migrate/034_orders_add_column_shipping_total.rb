class OrdersAddColumnShippingTotal < ActiveRecord::Migration
  def self.up
    add_column :orders, :shipping_total, :decimal, :scale => 4, :precision => 15
  end

  def self.down
    remove_column :orders, :shipping_total
  end
end
