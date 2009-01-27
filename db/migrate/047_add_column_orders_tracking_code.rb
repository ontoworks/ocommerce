class AddColumnOrdersTrackingCode < ActiveRecord::Migration
  def self.up
    add_column :orders, :tracking_code, :string
  end

  def self.down
  end
end
