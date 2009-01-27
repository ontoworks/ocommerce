class CreateWarranties < ActiveRecord::Migration
  def self.up
    create_table :warranties do |t|
      t.string :title
      t.string :context
      t.integer :product_id
      t.integer :category_id
      t.float :price
      t.timestamps
    end
  end

  def self.down
    drop_table :warranties
  end
end
