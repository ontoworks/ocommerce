class ProductsAddColumnFreight < ActiveRecord::Migration
  def self.up
    add_column :products, :freight, :boolean
  end

  def self.down
  end
end
