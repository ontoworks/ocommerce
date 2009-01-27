class Cart < ActiveRecord::Base
  has_many :cart_items
  belongs_to :discount
  belongs_to :user

  def add_product(product, price)
    current_item = self.cart_items.find_by_product_id(product.id)
    if current_item
      current_item.increment_quantity
      current_item.total = current_item.quantity*price
#      current_item.quantity
      current_item
    else
      item = CartItem.new({:product_id => product.id, :quantity => 1,
              :product_price => price})
      self.cart_items << item
#      item.quantity
      item
    end
  end

  def add_kit(kit)
    current_item = self.cart_items.find_by_kit_id(kit.id)
    if current_item
      current_item.increment_quantity
      current_item.total = current_item.quantity*kit.price
#      current_item.quantity
      current_item
    else
      item = CartItem.new({:kit_id => kit.id, :quantity => 1,
              :product_price => kit.price})
      self.cart_items << item
#      item.quantity
      item
    end
  end

  def update_qty(product_id, qty)
    item = self.cart_items.find(:first, :conditions => ["product_id=?", product_id])
    @items_count = self.cart_items.count
    if qty.to_i == 0
      item.destroy
    else
      total = qty*item.product_price
      item.update_attributes({:quantity => qty })
    end
  end

  def delete_by_product(product_id)
    item = self.cart_items.find(:first, :conditions => ["product_id=?", product_id])
    item.destroy
  end

  def remove_kit(kit_id)
    item = self.cart_items.find(:first, :conditions => ["kit_id=?", kit_id])
    item.update_attribute("product_price", 0)
    item.save
    item.destroy
  end

  def total_weight
    weight = 0
    cart_items.each do |item|
      weight += item.weight
    end
    weight
  end

  def contained_products
    products_in_cart = []
    cart_items.each do |i|
      if i.product
          products_in_cart << i.product
      elsif i.kit
        for p in i.kit.products
          products_in_cart << p
        end
      end
    end
    products_in_cart
  end
  
  def max_item_weight
    items = []
    #    cart_items.each { |i| items << (i.product.weight)}
    
    # included because of kits. should be made into method
    #    contained_products.each { |p| items << (p.weight)}
    contained_products.each do |p|
      if p.freight
        items << (p.weight)
      end
    end
    items.max
  end

  def empty?
    self.cart_items.empty?
  end

  # This price doesn't include taxes
  def total_price
    price = 0
    cart_items.each do |item|
      price += item.price # price es un metodo con el total del item (precio*cantidad)
      if item.has_warranty?
        price += item.warranty.price * item.quantity
      end
    end
    price
  end

  def totalize
    (total_price-(discount_price||0)).to_f
  end

  def totalize_products
    cart_items.to_a.sum { |i| i.price }
  end

  def totalize_items
    total_price
  end
end
