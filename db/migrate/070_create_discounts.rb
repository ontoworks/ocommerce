class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.string :type
      t.string :name
      t.string :discount_by
      t.float :value
      t.date :date_up
      t.date :date_down
      t.float :min_price
      t.float :max_price
      t.timestamps

      # attributes for type=Coupon
      t.string :code
      t.integer :use_times
    end
  end

  def self.down
    drop_table :discounts
  end
end
