class OrderItemsAddColumnWarrantyId < ActiveRecord::Migration
  def self.up
    add_column :order_items, :warranty_id, :integer
  end

  def self.down
  end
end
