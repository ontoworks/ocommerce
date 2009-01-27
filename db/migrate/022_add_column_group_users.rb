class AddColumnGroupUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :usergroup, :string
  end

  def self.down
    remove_column :users, :usergroup
  end
end
