module ProductsHelper
  def brands
    @brands = []
    for b in Brand.find(:all)
      @brands << [b.id.to_s, b.name]
    end
    @brands.to_json
  end
end
