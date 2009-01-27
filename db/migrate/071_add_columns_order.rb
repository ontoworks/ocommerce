class AddColumnsOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :discount_id, :integer
    add_column :orders, :discount_price, :float
  end

  def self.down
    remove_column :orders, :discount_id
    remove_column :orders, :discount_price
  end
end
