class AddColumnOrderItemsProductPrice < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :product_price, :decimal, :scale => 4, :precision => 15
  end

  def self.down
  end
end
