xml.response do
  xml.product_description do
    xml.specs(@specs.specs)
    xml.features(@specs.features)
    xml.includes(@specs.includes)
    xml.overview(@specs.overview)
    xml.features_desc(@specs.features_desc)
    xml.warranty(@specs.warranty)
    xml.main_info(@product.description)
  end
end

