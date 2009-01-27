class CreatePlants < ActiveRecord::Migration
  def self.up
    create_table :plants do |t|
      t.string :common
      t.string :botanical
      t.string :light
      t.float :price
      t.date :availability
      t.boolean :indoor

      t.timestamps
    end
  end

  def self.down
    drop_table :plants
  end
end
