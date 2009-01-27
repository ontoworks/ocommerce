class OrderItemsChangeColumnQuantity < ActiveRecord::Migration
  def self.up
    change_column :order_items, :quantity, :integer
  end

  def self.down
  end
end
