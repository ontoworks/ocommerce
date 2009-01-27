class CreateKits < ActiveRecord::Migration
  def self.up
    create_table :kits do |t|
      t.integer :product_id
      t.integer :type_id
      t.integer :price_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kits
  end
end
