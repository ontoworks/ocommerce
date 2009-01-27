class KitsAddColumnKitType < ActiveRecord::Migration
  def self.up
    add_column :kits, :kit_type, :string
  end

  def self.down
    remove_column :kits, :kit_type
  end
end
