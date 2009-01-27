class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :kit
  belongs_to :warranty

  def has_warranty?
    !warranty.nil?
  end

  def total
    totalize_product+totalize_warranty
#    0
  end

  def totalize_product
    product_price*quantity
  end

  def totalize_warranty
    price = 0
    if has_warranty?
      price = warranty.price*quantity
    end
    price
  end
end

## * self.product.price o self.product_price ?
##
##
##
