class AddRemoveColumnsCoupons < ActiveRecord::Migration
  def self.up
    remove_column :coupons, :type
    remove_column :coupons, :discount_type
    add_column :coupons, :price_off, :decimal, :precision => 8, :scale => 2
    add_column :coupons, :percent_off, :decimal, :precision => 4, :scale => 2
  end

  def self.down
  end
end
