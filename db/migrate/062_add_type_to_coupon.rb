class AddTypeToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :type, :string
  end

  def self.down
    remove_column :coupons, :type
  end
end
