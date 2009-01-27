class CategoriesChangeColumnName < ActiveRecord::Migration
  def self.up
    rename_column :categories, :name, :text
  end

  def self.down
    rename_column :categories, :text, :name
  end
end
