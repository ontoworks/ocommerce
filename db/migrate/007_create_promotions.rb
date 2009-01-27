class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.string :title
      t.date :start
      t.date :end
      t.integer :type_id
      t.integer :category_id
      t.integer :product_id
      t.integer :price_id
      t.integer :banner_id
      t.boolean :status
      t.timestamps
    end
  end

  def self.down
    drop_table :promotions
  end
end
