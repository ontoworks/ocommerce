class OrdersAddColumnsFreight < ActiveRecord::Migration
  def self.up
    add_column :orders, :freight_options, :integer
    add_column :orders, :freight_ship_to, :integer
  end

  def self.down
    remove_column :orders, :freight_options
    remove_column :orders, :freight_ship_to
  end
end
