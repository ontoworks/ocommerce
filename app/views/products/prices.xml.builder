xml.prices do
  xml.price do
    xml.customer(@customer_price)
    xml.business(@business_price)
    xml.wholesale(@wholesale_price)
  end
end
