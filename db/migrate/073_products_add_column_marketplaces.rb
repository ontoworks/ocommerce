class ProductsAddColumnMarketplaces < ActiveRecord::Migration
  def self.up
    add_column :products, :marketplaces, :string
  end

  def self.down
  end
end
