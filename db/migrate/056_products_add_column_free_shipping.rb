class ProductsAddColumnFreeShipping < ActiveRecord::Migration
  def self.up
    add_column :products, :free_shipping, :boolean
  end

  def self.down
    remove_column :products, :free_shipping
  end
end
