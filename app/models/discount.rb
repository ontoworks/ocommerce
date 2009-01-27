class Discount < ActiveRecord::Base
  has_many :orders
  has_many :carts
end
