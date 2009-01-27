class CreateShippingOptions < ActiveRecord::Migration
  def self.up
    create_table :shipping_options do |t|
      t.integer :shipping_module_id
      t.string :option
      t.boolean :active
      t.boolean :international
      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_options
  end
end
