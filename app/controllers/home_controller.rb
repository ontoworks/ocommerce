class HomeController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    query = "SELECT * FROM products WHERE is_hot = 1 ORDER BY RAND() LIMIT 8"
    @hot_products = Product.find_by_sql query

    @products = Product.find(:all, :order => "times_ordered DESC", :limit => 16)
    @categories = categories_list
    @supplies = Category.find(:all, :conditions => ["parent_id = ?", 210 ])
    @cart = find_cart

    session[:search_by] = {}
    session[:checkout] = false

    store_location
  end

  def add_kit_to_cart
    @kit = Kit.find(params[:id])
    @cart = find_cart

    ## Checks whether the product already in cart
    @product_in_cart = @cart.cart_items.find_by_product_id(@kit.product.id)
    @kit_in_cart = @cart.cart_items.find_by_kit_id(@kit.id)
    @product_item = @product_in_cart
    if @product_in_cart.nil?
      @product_item = @cart.add_product(@kit.product, @kit.product.price(usergroup))
    else
      @product_in_cart.product.kits.each do |k|
        @kit_in_cart = @cart.cart_items.find_by_kit_id(k.id)
        break if !@kit_in_cart.nil?
      end
    end



    @kit_item = @kit_in_cart
    if @kit_item.nil?
      @kit_item = @cart.add_kit(@kit)
    else
      if @kit_item.kit != @kit
        @cart.remove_kit(@kit_item.kit.id)
        # this must go to cart_item model
#        @kit_item.update_attributes({
#                                      :kit_id => @kit.id,
#                                      :quantity => 1,
#                                      :product_price => @kit.price
#                                    })
#        @kit_item.save!
        @kit_item = @cart.add_kit(@kit)
      else
        # if kit in cart and product qty > kit qty: add_kit
        if @product_item.quantity.to_i > @kit_item.quantity.to_i
          @kit_item = @cart.add_kit(@kit)
        end
      end
    end
    @qty = @kit_item.quantity
  end

  def add_to_cart
    @product = Product.find(params[:id])
    @cart = find_cart
    @item = @cart.add_product(@product, @product.price(usergroup))
    @qty = @item.quantity
  end

  def login
    @user = User.authenticate(params[:email], params[:password])
    redirect_back_or_default('/')
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

  def categories_list
    Category.find(:all)
  end

  def checkout
    redirect_to :controller => "cart", :action => "checkout"
  end

  def empty_cart
  end
end
