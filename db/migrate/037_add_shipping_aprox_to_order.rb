class AddShippingAproxToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :shipping_approx, :float
  end

  def self.down
    remove_column :orders, :shipping_approx
  end
end
