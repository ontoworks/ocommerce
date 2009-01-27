require 'RMagick'

class Product < ActiveRecord::Base
  attr_reader :price
#  acts_as_ferret :fields => [:name, :model, :description, :status]

  validates_uniqueness_of :model

  belongs_to :brand
  belongs_to :category

  has_one :product_description
  has_many :prices
  has_many :promotions
  has_many :cart_items
  has_many :kits
  has_many :kit_items
  has_many :order_items
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :warranties

  has_and_belongs_to_many :products

  has_and_belongs_to_many :cross_sell_products,
                          :join_table => 'cross_sells',
                          :foreign_key => 'product_id',
                          :association_foreign_key => 'cross_sell_product_id',
                          :class_name => 'Product',
                          :order => 'category_id'
#                          :limit => 3

  has_and_belongs_to_many :cross_seller_products,
                          :join_table => 'cross_sells',
                          :foreign_key => 'cross_sell_product_id',
                          :association_foreign_key => 'product_id',
                          :class_name => 'Product',
                          :order => 'category_id'
#                          :limit => 3

  def url
    product_name = self.name.downcase().gsub(/\s/, '_')
    product_name = product_name.downcase().gsub(/\//, '_')
    product_name = product_name.downcase().gsub(/\"/, '')
    "/products/#{self.id.to_s}-#{self.model}-#{product_name}"
  end

  def image_url
    if image != "no_image"
      "products/#{model}_thumb.jpg"
    else
      "products/no_image_thumb.jpg"
    end
  end

  def marketplaces
    self.[]("marketplaces").nil? ? nil : self.[]("marketplaces").split(",")
  end

  def marketplaces_to_s
    self.[]("marketplaces")
  end

  def marketplaces_to_s=(marketplaces)
    self.[]=("marketplaces", marketplaces)
  end

  def marketplaces=(list)
    self.[]=("marketplaces", list.join(","))
    self.save
  end

  def subscribed_to?(marketplace)
    self.marketplaces.nil? ? false : self.marketplaces.include?(marketplace)
  end

  def subscribe(marketplace)
    if !subscribed_to?(marketplace)
      subscriptions=self.marketplaces||[]
      subscriptions.push(marketplace)
      self.marketplaces=subscriptions
    end
  end

  def unsubscribe(marketplace)
    if subscribed_to?(marketplace)
      subscriptions=self.marketplaces||[]
      subscriptions.delete(marketplace)
      self.marketplaces=subscriptions
    end
  end

  def excategory
    self.categories[0]
  end

  def length1
    self.length
  end

  def price(usergroup)
    case usergroup
    when "business"
      self.business_price
    when "wholesale"
      self.wholesale_price
    else
      self.customer_price
    end
  end

  def customer_price
    price = Price.find(:first, :conditions => ["product_id = ? AND context = ?", self.id, "default"])
    if price.nil?
      0
    else
      price.price
    end
  end

  def price=(price)
    customer_price=price
    business_price=price
    wholesale_price=price
  end

  def customer_price=(price)
    @price = Price.find(:first, :conditions => ["product_id = ? AND context = ?", self.id, "default"])
    if @price.nil?
      self.prices << Price.new({:price => price, :context => "default"})
    else
      @price.update_attribute("price", price)
    end
  end

  def business_price=(price)
    @price = Price.find(:first, :conditions => ["product_id = ? AND context = ?", self.id, "business"])
    if @price.nil?
      self.prices << Price.new({:price => price, :context => "business"})
    else
      @price.update_attribute("price", price)
    end
  end

  def wholesale_price=(price)
    @price = Price.find(:first, :conditions => ["product_id = ? AND context = ?", self.id, "wholesale"])
    if @price.nil?
      self.prices << Price.new({:price => price, :context => "wholesale"})
    else
      @price.update_attribute("price", price)
    end
  end

  def business_price
    price = Price.find(:first, :conditions => ["product_id = ? AND context = ?", self.id, "business"])
    if price.nil?
      self.customer_price
    else
      price.price
    end
  end

  def wholesale_price
    price = Price.find(:first, :conditions => ["product_id = ? AND context = ?", self.id, "wholesale"])
    if price.nil?
      self.customer_price
    else
      price.price
    end
  end

  def has_promotions?
    if Promotion.count(:conditions => ["product_id = ?", self.id]) > 0
      true
    else
      false
    end
  end

  def has_kits?
    if self.kits.empty?
      false
    else
      kits.each do |k|
        return true if !k.products.empty?
      end
      false
    end
  end

  def platinum_kit
    kit = @Kit.find(:first, :conditions => ["product_id = ? AND kit_type = ?", self.id, "platinum"])
  end

  def gold_kit
    kit = @Kit.find(:first, :conditions => ["product_id = ? AND kit_type = ?", self.id, "gold"])
  end

  def silver_kit
    kit = @Kit.find(:first, :conditions => ["product_id = ? AND kit_type = ?", self.id, "silver"])
  end

  def has_cross_sellers?
    if self.cross_seller_products.empty?
      false
    else
      true
    end
  end

  def has_cross_sells?
    if self.cross_sell_products.empty?
      false
    else
      true
    end
  end

  def cross_sell_group
    if self.id == self.cross_sell_product_id.to_i
      return "Cross Sell"
    elsif self.id == self.product_id.to_i
      return "Cross Seller"
    end
  end

  def save_product_info(params)
    self.update_attributes({
      :name => params[:name],
      :height => params[:height],
      :weight => params[:weight],
      :width => params[:width],
      :description => params[:description],
      :model => params[:model],
      :condition => params[:condition],
      :brand_id => params[:brand],
      :length => params[:length1]
    })
  end

  def save_image(params)
    self.update_attribute("image", self.model+".jpg")
    f = File.new("public/images/products/"+self.model+".jpg", "wb")
    f.write params[:image].read
    f.close

    img = Magick::Image.read "public/images/products/#{self.model}.jpg"
    cols = img[0].columns
    rows = img[0].rows
    thumb = img[0].scale(75, 75*rows/cols)
    thumb.write "public/images/products/#{self.model}_thumb.jpg"
  end

  def self.paginate_like(query, order_by, sort, limit, page)
    @products = Product.paginate_by_sql(self.build_like_query(query, true),
      :page => page, :per_page => 16)

#      :order => order_by+' '+sort,
#      :limit => limit)
  end

  def self.find_like(query, active)
    Product.find_by_sql(self.build_like_query(query, active))
  end

  def self.count_by_like(query, active)
    Product.count_by_sql(self.build_like_query(query, active))
  end

  def self.build_like_query(query, active)
    keywords = []
    r = "(("
    q = query.split
    q.each do |k|
      r << "LOWER(name) LIKE '%#{k.downcase}%' AND "
    end
    r = r.to(r.length-5)
    r << ") "
    r << "OR LOWER(model) LIKE '%#{query.downcase}%')"
    r << " AND status='Y'" if active
    query = "SELECT * FROM products WHERE #{r}"
  end
end
