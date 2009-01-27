class AddCouponToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :coupon, :string
  end

  def self.down
    remove_column :orders, :coupon
  end
end
