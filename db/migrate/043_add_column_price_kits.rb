class AddColumnPriceKits < ActiveRecord::Migration
  def self.up
    remove_column :kits, :price_id
    add_column :kits, :price, :decimal, :precision => 6, :scale => 2
  end

  def self.down
  end
end
