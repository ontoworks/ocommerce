xml.shipping_modules do
  for s in @shippings
  xml.shipping_module do
    xml.active(s.active)
    xml.name(s.name)
    xml.from_weight(s.from_weight)
    xml.upto_weight(s.upto_weight)
  end
  end
end

