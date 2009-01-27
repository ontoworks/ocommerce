class CreateKitItems < ActiveRecord::Migration
  def self.up
    create_table :kit_items do |t|
      t.integer :kit_id
      t.integer :product_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kit_items
  end
end
