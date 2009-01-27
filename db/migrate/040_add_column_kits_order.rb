class AddColumnKitsOrder < ActiveRecord::Migration
  def self.up
    add_column :kits, :order, :integer
  end

  def self.down
    remove_column :kits, :order
  end
end
