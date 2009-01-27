class AdminPromotionController < ApplicationController
  layout "admin"


  before_filter :admin_only
  skip_before_filter :verify_authenticity_token

  def index
    @promotions = Promotion.find(:all)
    @promo_types = Type.find(:all, :conditions => {:classname => "promotion"})
  end

  def next
    @selected_promo_type = Type.find(params[:promotion][:type_id])
    @category = Category.find(1000)

    @promo_title = params[:promotion][:title]

    ## Add product or category promotion
    if params[:promotion][:add]
      Promotion.add(params)
    end

    ## Add quantity promotion
    if params[:promotion][:price_count]
      Promotion.add_prices_for_quantity(params)
    end
  end

  def ok
    if params[:promotion][:next] || params[:promotion][:quantity]
      product_re = /\((\d+)\)/
      m = product_re.match(params[:search][:name])
      @product = Product.find(m[1])
    end

    if !params[:search].nil?
      @product_name = params[:search][:name]
    end

    if !params[:promotion][:category_id].nil?
      @category = Category.find(params[:promotion][:category_id])
    end

    @value = params[:promotion][:value]
    @value_type = params[:promotion][:value_type]
  end

  def quantity
    @product = Product.find(params[:promotion][:product_id])

    @quantity = {}
    for i in 1..20
      qty = params[:promotion]["quantity_"+i.to_s]
      price = params[:promotion]["price_"+i.to_s]

      if !qty.nil?
        if !qty.empty? && !price.empty?
          if @quantity[qty].nil? && !(qty == 1)
            @quantity[qty] = price
          else
            return
          end
        else
          break
        end
      else
        return
      end      
    end
  end

  def auto_complete_for_search_name
    auto_complete_responder_for_search params[:search][:name]
  end

  private
  def auto_complete_responder_for_search(value)
    @products = Product.find(:all,
      :conditions => [ 'LOWER(name) LIKE ?',
      '%' + value.downcase + '%' ],
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'search'
  end
end
