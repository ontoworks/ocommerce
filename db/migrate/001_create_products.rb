class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :model, :string
      t.column :condition, :string
      t.column :image, :string
      t.column :status, :string
      t.column :manufacturer_id, :integer
      t.column :width, :decimal, :precision => 6, :scale => 2
      t.column :weight, :decimal, :precision => 6, :scale => 2
      t.column :height, :decimal, :precision => 6, :scale => 2
      t.column :length, :decimal, :precision => 6, :scale => 2
      t.column :times_ordered, :integer
      t.column :times_viewed, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
