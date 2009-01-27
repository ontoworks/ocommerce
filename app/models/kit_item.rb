class KitItem < ActiveRecord::Base
  belongs_to :kit
  belongs_to :product
end
