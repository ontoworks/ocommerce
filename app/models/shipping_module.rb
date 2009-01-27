class ShippingModule < ActiveRecord::Base
  has_many :shipping_options
end
