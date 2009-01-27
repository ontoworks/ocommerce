class CreateShippingModules < ActiveRecord::Migration
  def self.up
    create_table :shipping_modules do |t|
      t.string :name
      t.integer :from_weight 
      t.integer :upto_weight 
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_modules
  end
end
