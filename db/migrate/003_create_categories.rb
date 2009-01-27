class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name 
      t.text :description
      t.string :image
      t.integer :parent_id
      t.boolean :status
      t.integer :sort_order
      t.string :heading_title
      t.string :mkeywords
      t.string :mdescript
      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
