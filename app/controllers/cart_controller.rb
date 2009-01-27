class CartController < ApplicationController
  layout "cart" # , :except => :send_to_paypal

  require 'lib/gateways/google_checkout'
  skip_before_filter :verify_authenticity_token
  include SslRequirement
  include ShippingQuotes
  include Google4R::Checkout


#  ssl_required :customer_info, :shipping, :final_confirmation,
#  :send_to_paypal, :send_to_google, :direct_transaction, :freight_cost, :redeem_coupon


  before_filter(:ui_stuff)

  def home
    @cart = find_cart
    respond_to do |format|
      format.html
    end
  end

  def clear_cart
    @cart = find_cart
    @cart.cart_items.delete_all
    redirect_to :controller => 'home', :action => 'index'
  end

  def add_to_cart
    @product = Product.find(params[:id])
    @cart = find_cart
    @qty = @cart.add_product(@product)
  end

  def add_warranty
    @cart = find_cart
    @item = @cart.cart_items.find_by_product_id(params[:product_id])
    @warranty = Warranty.find(params[:id])
    @product = Product.find(params[:product_id])

    # Es necesario garantizar que existe el [objeto] warranty?
    # Esto debe ir sobre el [modelo] cart_item?
    @item.warranty = @warranty
    # Porque no guarda en la asignacion?
    @item.save

#    respond_to do |format|
#     format.xml { render :xml => @item }
#    end
  end

  def remove_warranty
    @item = CartItem.find(params[:id])
    @product = Product.find(@item.product_id)
    @item.warranty = nil
    @item.save
  end

  def remove_kit
    @kit = Kit.find(params[:id])
    @kit_id = params[:id]

    @cart = find_cart
    @cart.remove_kit(@kit_id)
  end

  # DELETE /cart/items/:cart_item_id
  def remove_item
    @cart = find_cart
    @item = CartItem.find(params[:cart_item_id])
    @cart.cart_items.destroy(@item)
  end

  # DELETE /cart/products/:product_id
  def remove_product
    @id = params[:product_id]
    @cart = find_cart

    @cart.delete_by_product(params[:product_id])

    @cart.cart_items.each do |i|
      if i.kit
        if i.kit.product.id.to_s == @id.to_s
          @remove_kit = i.kit
          CartItem.delete(i.id)
        end
      end
    end
  end

  ## CHECKOUT HEREON
  def checkout
  end

  def login
    session[:checkout] = true
    if logged_in?
      redirect_to step2_path
    else
      store_location
      redirect_to :action => "new", :controller => "sessions"
    end
  end

  def update_qty
    @id = params[:id]
    @qty = params[:qty]
    @cart = find_cart
    @cart.update_qty(@id, @qty)
  end

  def customer_info
    @cart = find_cart
    if (@cart.nil? || @cart.empty?)
      redirect_to_index("Your cart is empty.")
    end
    @order = session[:order] || Order.new
    @cart = find_cart
    @user = current_user
    logger.info @user
  end

  def shipping
    debugger
    session[:after_shipping] = true
    session[:coupon] = ""
    @cart = find_cart

    @order = Order.new(params[:order])

    if @order.valid?
      @order.status = Order::PENDING
      session[:order] = @order

      # All free shipping
      @all_free_shipping = true
      session[:all_free_shipping] = true

#      @products_in_cart = []
#      @cart.cart_items.each do |i|
#        if i.product
#          @products_in_cart << i.product
#        elsif i.kit
#          for p in i.kit.products
#            @products_in_cart << p
#          end
#        end
#      end

#      @cart.cart_items.each do |i|
#        if !i.product.free_shipping
#          @all_free_shipping = false
#          session[:all_free_shipping] = false
#        end
#      end

      @cart.contained_products.each do |product|
        if !product.free_shipping
          @all_free_shipping = false
          session[:all_free_shipping] = false
        end
      end
      redirect_to :action => "final_confirmation" if @all_free_shipping
    else
      session[:order] = @order
      render :action => "customer_info"
    end
  end

  # Show the info. one last time before processing the order
  def final_confirmation
    if session[:all_free_shipping]
      carrier = "Free Shipping"
      method = "Free Shipping"
    else
      order_id = params[:order][:id]
      carrier = params[:order][:carrier]
      method = params[:order][:shipping_method]
    end

    coupon_code = session[:coupon]

    @cart = find_cart
    @order = session[:order]

    @order.set_freight_ship_to session[:ship_to]
    @order.set_freight_options session

    if valid_coupon_code?(coupon_code, @order.totalize_items)
      @order.coupon = coupon_code
    end

    @order.carrier = carrier
    @order.taxes = round(@cart.totalize_products * state_tax(@order.billing_state)).to_f
    @order.shipping_method = shipping_method(method)
    @order.shipping_approx = shipping_approx(@order.carrier, method)
    session[:order] = @order
  end

  def freight_cost
    @data = {}
    @data[:options] = params[:options]
    @data[:weight] = params[:options][:weight]
    @data[:to_zip] = params[:options][:to_zip]

    session[:liftcharge] = params[:options][:liftcharge]
    session[:inside_delivery] = params[:options][:inside_delivery]
    session[:ship_to] = params[:options][:conditions]
  end

  def redeem_coupon
    @p = params
    code = params[:coupon][:code]
    @error = nil
    @coupon = Coupon.find_by_code(code.upcase)
#    debugger
    if @coupon != nil
      if @coupon.is_current?
        if @coupon.applies_to_order?(@cart)
          @cart = find_cart
          @order = session[:order]
          @order.discount=@coupon
          @order.discount_price=@coupon.percent_discount? ? (@coupon.value*@cart.total_price/100).to_f.round(2) : @coupon.value
          @coupon.users << current_user
        else
          @error = "The coupon entered only applies to orders between #{@coupon.min_price} and #{@coupon.max_price}"
        end
      else
        @error = "The coupon entered is no longer valid"
      end
    else
      @error = "No coupon exists for entered code"
    end
  end

  # Processes the order through Google Checkout
  def send_to_google
    @cart = find_cart
    @order = session[:order]
    dump_cart_items(@order, @cart)
    Postoffice.deliver_new_order(@order, current_user.email)
    gateway = Gateways::GoogleGateway.new(false)
    gateway.add_shipping_method(Google4R::Checkout::FlatRateShipping, @order.shipping_method, @order.shipping_approx)
    gateway.add_items_to_cart(@cart)
    redirect_to gateway.checkout_uri
    clear_session
  end

  # Processes the order through Paypal Express
  def send_to_paypal
    @cart = find_cart
    @order = session[:order]
    dump_cart_items(@order, @cart)
    Postoffice.deliver_new_order(@order, current_user.email)
    clear_session
  end

  def send_to_direct
    @cart = find_cart
    @order = session[:order]

    dump_cart_items(@order, @cart)
    Postoffice.deliver_new_order(@order, current_user.email)
    clear_session
  end

  def direct_transaction
    @cart = find_cart
    @order = session[:order]
    dump_cart_items(@order, @cart)
    @order.user_id = current_user.id
    @order.name = current_user.firstname + " " + current_user.lastname
    @order.payment_method = "credit card" # params[:payment_method] || params[:order][:payment_method]
    @order.status = Order::PENDING
    ord = params[:order]

    coupon = Coupon.find_by_code(@order.coupon)

# Comentando todo hasta estar listos
#    if coupon
#       ap = AppliedDiscount.create({ :order_id => @order,
#                                  :discount_type => coupon.discount_type,
#                                  :discount_id => coupon,
#                                  :price_off => calculate_discount(coupon, @order.totalize_items)
#                                })
#     end



    @order.cc_owner = ord[:cc_owner]
    @order.cc_type = ord[:cc_type]
    @order.cc_expires = ord[:cc_expires]
    @order.cc_number = ord[:cc_number].gsub(/-| /, "")
    @order.cvvnumber = ord[:cvvnumber]
    clear_session
    if @order.valid?
      @order.save!
      Postoffice.deliver_new_order(@order, current_user.email)
      redirect_to :action => "thank_you", :id => @order.id
    else
      render :action => "send_to_direct"
    end
  end

  def gateway_link
    order = session[:order]
    order.payment_method = params[:payment_method] || params[:order][:payment_method]
    order.status = Order::PENDING
    order.user_id = current_user.id
    order.name = current_user.firstname + " "  + current_user.lastname
    order.save!
    case order.payment_method
    when "google"
      meth = "send_to_google"
    when "paypal"
      meth = "send_to_paypal"
    when "direct"
      meth = "send_to_direct"
    end
    redirect_to({:action => meth, :id => order.id})
  end

  def thank_you
    @order = Order.find(params[:id])
  end

  private

  def redirect_to_index(msg)
    flash[:notice] = msg
    redirect_to :controller => "home", :action => "index"
  end

  def categories_list
    Category.find(:all)
  end

  def dump_cart_items(order, cart)
    cart.cart_items.each do |ci|
      if ci.kit
        o = OrderItem.new( :kit_id => ci.kit.id,
                           :product_price => ci.kit.price,
                           :quantity => ci.quantity)
        order.order_items << o
      else
        o = OrderItem.new( :product_id => ci.product_id,
                           :product_name => ci.product.name,
                           :product_model => ci.product.model,
                           :product_price => ci.product.price(current_user.usergroup),
#                         :final_price => ci.totalize_products,
                           :quantity => ci.quantity,
                           :warranty_id => ci.warranty_id)
        order.order_items << o
      end
    end
  end

  def shipping_approx(carrier, cost_string)
    if cost_string.nil? || cost_string.empty?
      return 330.to_f
    end
    if carrier == "Freight"
#      debugger
      c = cost_string.split("-")[2][1..-1]
    else
      c = cost_string.split("-")[2]
    end
    c.to_f
  end


  def ui_stuff
    @cart = find_cart
    @categories = categories_list
    @supplies = Category.find(:all, :conditions => ["parent_id = ?", 210 ])
  end

  def valid_coupon_code?(code, total)
    today = Date.today
    coupon = Coupon.find_by_code(code)

    !coupon.nil? && between?(today, coupon.date_down, coupon.date_up) &&
    between?(total, coupon.order_total_low, coupon.order_total_up) && coupon.use_times > 0
  end

  def calculate_discount(coupon, total)
    case coupon.discount_type
      when "price" then return coupon.value
      when "percentage" then return (total * (coupon.value / 100))
    end
    0
  end

  def between?(c, low, high)
    c <= high && c >= low
  end

  def shipping_method(meth_string)
    meth_string.split("-")[1]
  end

  def clear_session
    if session
      session[:order] = nil
      session[:cart] = nil
    end
  end
end
