class AddColumnCartItemsTotal < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :total, :decimal, :precision => 8, :scale => 2
  end

  def self.down
  end
end
