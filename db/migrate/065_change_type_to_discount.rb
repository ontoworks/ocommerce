class ChangeTypeToDiscount < ActiveRecord::Migration
  def self.up
    add_column :coupons, :discount_type, :string
  end

  def self.down
    remove_column :coupons, :discount_type
  end
end
