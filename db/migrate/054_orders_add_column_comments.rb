class OrdersAddColumnComments < ActiveRecord::Migration
  def self.up
    add_column :orders, :comments, :text
  end

  def self.down
  end
end
