class AddTaxesToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :taxes, :float
  end

  def self.down
    remove_column :orders, :taxes
  end
end
