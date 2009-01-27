class CouponsUsers < ActiveRecord::Migration
  def self.up
    create_table :coupons_users, :id => false do |t|
      t.integer :coupon_id
      t.integer :user_id
    end
  end

  def self.down
  end
end
