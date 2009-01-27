class AddColumnQuantityToPrices < ActiveRecord::Migration
  def self.up
    add_column :prices, :quantity, :integer
  end

  def self.down
    remove_column :prices, :quantity
  end
end
