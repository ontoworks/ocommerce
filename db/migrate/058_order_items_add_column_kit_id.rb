class OrderItemsAddColumnKitId < ActiveRecord::Migration
  def self.up
    add_column :order_items, :kit_id, :integer
  end

  def self.down
    add_column :order_items, :kit_id
  end
end
