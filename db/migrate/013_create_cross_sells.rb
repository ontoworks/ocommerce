class CreateCrossSells < ActiveRecord::Migration
  def self.up
    create_table :cross_sells do |t|
      t.integer :product_id
      t.integer :cross_sell_product_id
      t.integer :cs_position
    end
  end

  def self.down
    drop_table :cross_sells    
  end
end
