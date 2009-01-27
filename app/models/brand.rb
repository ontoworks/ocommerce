class Brand < ActiveRecord::Base
  has_many :products
  def products_count
    products.count
  end
end
