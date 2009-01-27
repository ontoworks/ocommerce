class Kit < ActiveRecord::Base
  belongs_to :product
  has_many :kit_items
  has_many :products, :through => :kit_items

  def save_image(params)
    filename = self.product_id.to_s+"-"+self.kit_type+"_kit"
    self.update_attribute("image", filename)
    f = File.new("public/images/products/"+filename+".jpg", "wb")
    f.write params[:image].read
    f.close

    img = Magick::Image.read "public/images/products/#{filename}.jpg"
    cols = img[0].columns
    rows = img[0].rows
    thumb = img[0].scale(75, 75*rows/cols)
    thumb.write "public/images/products/#{filename}_thumb.jpg"
  end

  def products_total
#    products.inject { |sum, p| sum + p.price("customer") }
    sum = 0
    products.each { |p| sum += p.price("customer") }
    sum
  end

  def discounts
    products_total.to_f-price.to_f
  end
end
