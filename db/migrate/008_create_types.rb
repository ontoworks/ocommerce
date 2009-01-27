class CreateTypes < ActiveRecord::Migration
  def self.up
    create_table :types do |t|
      t.string :text
      t.string :classname
      t.timestamps
    end
  end

  def self.down
    drop_table :types
  end
end
