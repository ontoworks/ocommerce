class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :warranty
  belongs_to :kit

  def has_warranty?
    !self.warranty.nil?
  end

  def increment_quantity
    self.update_attribute("quantity", self.quantity+1)
  end

  def price
    self.product_price * self.quantity
  end

  def unit_price
    self.product_price
  end

  def weight
    if self.quantity > 1
      if self.kit
        return self.kit.product.weight * 15
      else
        return self.product.weight * 15
      end
    else
      if self.kit
        return self.kit.product.weight
      else
        return self.product.weight
      end
    end
  end

  def name
    product.name
  end

  def description
    product.description
  end

  def model
    product.model
  end

  def totalize
    self.price
  end
end
