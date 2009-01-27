class FixAppliedDiscount < ActiveRecord::Migration
  def self.up
    remove_column :applied_discounts, :string
    add_column :applied_discounts, :discount_type, :string
  end

  def self.down
#    add_column :applied_discounts, :string, :integer
    remove_column :applied_discounts, :type
  end
end
