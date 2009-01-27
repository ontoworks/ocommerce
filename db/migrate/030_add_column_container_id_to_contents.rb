class AddColumnContainerIdToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :content_container_id, :integer
  end

  def self.down
    remove_column :contents, :content_container_id
  end
end
