class ProductsRenameColumnManufacturer < ActiveRecord::Migration
  def self.up
    rename_column :products, :manufacturer_id, :brand_id
  end

  def self.down
    rename_column :products, :brand_id, :manufacturer_id
  end
end
