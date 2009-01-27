class AddColumnProductsIsHot < ActiveRecord::Migration
  def self.up
    add_column :products, :is_hot, :boolean
  end

  def self.down
  end
end
