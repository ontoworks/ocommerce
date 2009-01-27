

class AddNewFieldsToUser < ActiveRecord::Migration
  def self.up
#    add_column :users, :company, :string
#    add_column :users, :street_address, :string
 #   add_column :users, :city, :string
#    add_column :users, :zip_code, :string
#    add_column :users, :state, :string
#    add_column :users, :country, :string
#    add_column :users, :telephone, :string
#    add_column :users, :firstname, :string
#    add_column :users, :lastname, :string
#    add_column :users, :crypted_password, :string
  end


  def self.down
    remove_column :users, :company
    remove_column :users, :street_address
    remove_column :users, :city
    remove_column :users, :zip_code
    remove_column :users, :state
    remove_column :users, :country
    remove_column :users, :telephone
    remove_column :users, :firstname
    remove_column :users, :lastname
    remove_column :users, :crypted_password
    end
end
