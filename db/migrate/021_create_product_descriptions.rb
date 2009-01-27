class CreateProductDescriptions < ActiveRecord::Migration
  def self.up
    create_table :product_descriptions do |t|
      t.integer :product_id
      t.text :specs
      t.text :features
      t.text :includes
      t.text :warranty
      t.text :overview
      t.text :features_desc
      t.timestamps
    end
  end

  def self.down
    drop_table :product_descriptions
  end
end
