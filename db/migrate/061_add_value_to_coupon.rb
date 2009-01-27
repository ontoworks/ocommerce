class AddValueToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :value, :float
  end

  def self.down
    remove_column :coupons, :value
  end
end
