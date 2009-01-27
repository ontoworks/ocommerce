class CreateProductsWarranties < ActiveRecord::Migration
  def self.up
    create_table :products_warranties, :id => false do |t|
      t.integer :warranty_id
      t.integer :product_id
    end
  end

  def self.down
    drop_table :products_warranties
  end
end
