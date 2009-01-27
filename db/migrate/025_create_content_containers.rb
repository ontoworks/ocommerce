class CreateContentContainers < ActiveRecord::Migration
  def self.up
    create_table :content_containers do |t|
      t.string :name
      t.integer :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table :content_containers
  end
end
