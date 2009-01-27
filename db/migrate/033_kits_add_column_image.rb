class KitsAddColumnImage < ActiveRecord::Migration
  def self.up
    add_column :kits, :image, :string
  end

  def self.down
    remove_column :kits, :image
  end
end
