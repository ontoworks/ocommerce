class Promotion < ActiveRecord::Base
  belongs_to :product
  belongs_to :category
  belongs_to :type

  def self.add(params)
    @promotion = Promotion.new({
                     :title => params[:promotion][:title],
                     :start => params[:promotion][:start],
                     :end => params[:promotion][:end],
                     :type_id => params[:promotion][:type_id],
                     :status => true })

    case params[:promotion][:apply_to]
    when "product"
      product_re = /\((\d+)\)/
      m = product_re.match(params[:search][:name])
      @promotion.product_id = m[1]
    when "category"
      @promotion.category_id = params[:promotion][:category_id]
    when "order"
    end

    case params[:promotion][:value_type]
    when "percent"
      @promotion.percent = params[:promotion][:value]
    when "price_off"
      @promotion.price_off = params[:promotion][:value]
    end

    @promotion.save
  end

  def self.add_prices_for_quantity(params)
    product = Product.find(params[:promotion][:product_id])
    price_count = params[:promotion][:price_count]

    for i in 1..price_count.to_i
      price = Price.new({
        :price => params[:promotion]["price_"+i.to_s],
        :context => "quantity",
        :quantity => params[:promotion]["qty_"+i.to_s]
      })
      product.prices << price
    end

    promotion = Promotion.new({
                     :title => params[:promotion][:title],
                     :start => params[:promotion][:start],
                     :end => params[:promotion][:end],
                     :type_id => params[:promotion][:type_id],
                     :status => true })

    product.promotions << promotion 
  end

  def applies_to_product?
    !self.product_id.nil? ? true : false
  end

  def applies_to_category?
    !self.category_id.nil? ? true : false
  end

  def is_value_percent?
    !self.percent.nil? ? true : false
  end

  def is_value_price_off?
    !self.price_off.nil? ? true : false
  end

  def is_quantity_promo?
    self.type.text == "quantity" ? true : false
  end
end
