class CartItemsAddColumnWarrantyId < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :warranty_id, :integer
  end

  def self.down
  end
end
