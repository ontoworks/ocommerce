xml.response do
  xml.product do
    xml.condition(@product.condition)
    xml.created_at(@product.created_at)
    xml.description(@product.description)
    xml.height(@product.height)
    xml.id(@product.id)
    xml.image(@product.image)
    xml.length(@product.length)
    xml.length1(@product.length1)
    xml.category(@product.category.id)
    xml.brand(@product.brand.name)
    xml.model(@product.model)
    xml.name(@product.name)
    xml.status(@product.status)
    xml.times_ordered(@product.times_ordered)
    xml.times_viewed(@product.times_viewed)
    xml.updated_at(@product.updated_at)
    xml.weight(@product.weight)
    xml.width(@product.width)
    xml.is_hot(@product.is_hot)
    xml.freight(@product.freight)
    xml.free_shipping(@product.free_shipping)
    xml.pricegrabber(@product.subscribed_to?("pricegrabber"))
    xml.nextag(@product.subscribed_to?("nextag"))
    xml.shopzilla(@product.subscribed_to?("shopzilla"))
  end
end

