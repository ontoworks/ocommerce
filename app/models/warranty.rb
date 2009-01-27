class Warranty < ActiveRecord::Base
  has_and_belongs_to_many :products
  has_many :cart_items
end
