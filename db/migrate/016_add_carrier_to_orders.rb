class AddCarrierToOrders < ActiveRecord::Migration
  def self.up
    add_column "orders", "carrier", :string
  end

  def self.down
  end
end
