
module CartHelper

  require 'lib/taxes'

  include ShippingQuotes

  def order_finished?
    false
    if @uri =~ /thank_you/
      if !@order.nil?
        true
      end
    end
  end

  def print_cart_items(cart)
    string = "<table><tr>"
    string << "<td><b>Name</b></td>"
    string << "<td><b>Quantity</b></td>"
    string << "<td><b>Price</b></td></tr>"
    cart.cart_items.each do |item|
      string << "<tr>"
      string << "<td>#{item.name}</td>"
      string << "<td><center> <b>#{item.quantity}</b></center></td>"
      string << "<td>#{item.price}</td>"
      string << "</tr>"
    end
    string << "</table>"
    string
  end

  def print_shipping_info(order)
    string = ""
    string << "#{order.delivery_name}<br/>"
    string << "#{order.delivery_company}<br />"
    string << "#{order.delivery_street_address}, "
#    string << "#{order.delivery_suburb}, "
    string << "#{order.delivery_city}<br />"
    string << "#{order.delivery_postcode}, "
    string << "#{$us_states[order.delivery_state].nil? ? order.delivery_state.capitalize : $us_states[order.delivery_state].capitalize}, "
    string << "#{order.delivery_country}<br />"
    string << "Shipping with: #{order.carrier}"
#    if order.carrier =~ /Freight/
#      options = order.freight_options||0
#      ship_to = order.freight_ship_to||0
#      string << "<br/>Freight options:#{Order::FREIGHT_OPTIONS[options]}<br />"
#      string << "Freight ship to:#{Order::FREIGHT_SHIP_TO[ship_to]}"
#    end
    string
  end


  def print_billing_info(order)
#    email = (order.email_address.nil? || order.email_address.empty?)? order.user.email : order.email_address

    string = ""
    string << "#{order.billing_name}<br/>"
    string << "#{order.billing_company}<br />"
    string << "Phone number: #{order.telephone}<br/>"
#    string << "Email: #{ema<br/>"
    string << "#{order.billing_street_address}, "
#    string << "#{order.billing_suburb}, "
    string << "#{order.billing_city}<br />"
    string << "#{order.billing_postcode}, "
#    string << "#{$us_states[order.billing_state].capitalize}, "
    string << "#{$us_states[order.billing_state].nil? ? order.billing_state : $us_states[order.billing_state].capitalize}, "
    string << "#{order.billing_country}<br /><br />"
    string << "Pay with: #{nice_payment_info(order.payment_method)}"
    string
  end

  def js_fill_info
    "getElementById('order_billing_name').value = getElementById('order_delivery_name').value;
     getElementById('order_billing_company').value = getElementById('order_delivery_company').value;
     getElementById('order_billing_street_address').value = getElementById('order_delivery_street_address').value;
     getElementById('order_billing_suburb').value = getElementById('order_delivery_suburb').value;
     getElementById('order_billing_city').value = getElementById('order_delivery_city').value;
     getElementById('order_billing_postcode').value = getElementById('order_delivery_postcode').value;
     getElementById('order_billing_state').value = getElementById('order_delivery_state').value;
     getElementById('order_billing_country').value = getElementById('order_delivery_country').value;"
  end

  def nice_payment_info(info)
    case info
    when "google"
      "Google Checkout"
    when /paypal/
      "Paypal"
    when "direct", "credit card"
      "Credit Card"
    end
  end

  def price_after_taxes(order, cart)
    price = cart.total_price + order.taxes
    round(price)
  end

  def shipping_carriers(cart)
    c = []
    max_item_weight = cart.max_item_weight
    case max_item_weight
    when (0..10)
      c = ["DHL", "FedEX", "UPS"]
    when 0..85
      c = ["UPS", "FedEX", "Freight"]
    when 85..300000
      c = ["Freight"]
    end
    return c
  end

  def regular_shipping_methods(carrier, order, cart)
    to_zip = order.delivery_postcode
    radios = ""
    shipping_methods.each do |sm|
      sm_price = shipping_price(carrier, to_zip, cart, sm, nil).to_s
      next if sm_price == "0"
      radio_value = carrier + "-" + sm + "-" + sm_price
      html_value = sm + " - $ " + sm_price + "<br/>"
      button = radio_button(:order, :shipping_method, radio_value) + html_value
      radios << button
    end
    radios
  end


  def freight_shipping_methods(carrier, zip_code, weight, opts)
    if opts.nil?
      methods = shipping_price(carrier, zip_code.to_i, weight.to_i, nil)
    else
      methods = shipping_price(carrier, zip_code.to_i, weight.to_i, nil, opts)
    end
    radios = ""
    sorted = methods.to_a.each{|arr| arr.reverse!}
    sorted.sort_by{|a|a[0][1..-1].to_i}.each do |a|
      a.reverse!
      k = a[0]
      v = a[1]
      radio_value = carrier + "-" + k + "-" + v
      radios << radio_button(:order, :shipping_method, radio_value, :checked => true) << k  << " - " << v << "<br/>"
    end

    return radios
  end

  def shipping_price(carrier, to_zip, cart, method, opts)
    shipping_quote(carrier, to_zip, cart, method, opts)
  end

  def print_shipping_price(o, cart, opts)
    carrier = o.carrier
    weight = cart.total_weight
  end

  def print_subtotal(order, cart)
    "<b>Subtotal (before shipping):</b> $ #{price_after_taxes(order, cart)}<br/><br/>"
  end

  def round(f)
    s = f.to_s
    if (s =~ /(\d+\.\d?\d?)\d*/)
      return $1.to_f
    else
      raise StandardError.new("Sometihng")
    end
  end

end
