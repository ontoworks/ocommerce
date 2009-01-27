class OrdersAddColumnFrontComment < ActiveRecord::Migration
  def self.up
    add_column :orders, :front_comment, :text
  end

  def self.down
    remove_column :orders, :front_comment
  end
end
