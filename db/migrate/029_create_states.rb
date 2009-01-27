class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.string :full_name
      t.string :short_name
      t.float :tax

      t.timestamps
    end

    State.create(:full_name => "Texas", :short_name => "TX", :tax => 8.25)
  end

  def self.down
    drop_table :states
  end
end
