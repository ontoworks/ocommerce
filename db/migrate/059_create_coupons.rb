class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.date :date_up
      t.date :date_down
      t.integer :use_times
      t.integer :order_total_up
      t.integer :order_total_low

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
