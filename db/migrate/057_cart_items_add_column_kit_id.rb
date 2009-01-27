class CartItemsAddColumnKitId < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :kit_id, :integer
  end

  def self.down
    remove_column :cart_items, :kit_id
  end
end
