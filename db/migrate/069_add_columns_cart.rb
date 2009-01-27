class AddColumnsCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :discount_id, :integer
    add_column :carts, :discount_price, :float
  end

  def self.down
    remove_column :carts, :discount_id
    remove_column :carts, :discount_price
  end
end
