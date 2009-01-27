require 'rubygems'
require 'shipping'
require 'shipping_calc'

# === Usage
# This module handles all the shipping quotes using the different APIs. Right
# now, calculations for UPS are made through the "shipping" gem
# (http://shipping.rubyforge.org).
#
# To get a quote from a specific carrier, the command would be something
# like:
#
#     include ShippingQuotes
#     p shipping_quote(carrier, zip, weight_in_lbs, shipping_method)
#
# Where the first value defines the carrier (right now it only supports UPS),
# zip is the zip code where it'll be sent, weight is the package's total
# weight in lbs. and shipping method is the Shipping Gem's code of the
# shipping method that will be used (2day, next_day, etc).
#
# === Authors
# * Federico Builes  (mailto:federico.builes@gmail.com)
module ShippingQuotes

  # UPS' shipping methods
  UPSMethods = {
    "2day" => "2 Day Shipping",
    "ground_service" => "Ground Service",
    "next_day" => "Next Day Shipping"
  }

  # DHL's shipping methods
  DHLMethods = {
    "S" => "2 Day Shipping",
    "G" => "Ground Service",
    "E" => "Next Day Shipping"
  }

  # Approximate value of sending something to "zip" using "carrier" and the
  # specified "method". The total weight of the package must be entered in weight.
  def shipping_quote(carrier, zip, cart, method, fq_opts = nil)
    p = 0
    if carrier != "Freight"
      cart.cart_items.each do |ci|
        if ci.kit
          ci.kit.products.each do |product|
            if product.free_shipping
              next
            end
            case carrier
            when "UPS"
              p += ups_quote(zip, product.weight, method) * ci.quantity
            when "DHL"
              p += dhl_quote(zip, product.weight, method) * ci.quantity
            when "FedEX"
              p += fedex_quote(zip, product.weight, method) * ci.quantity
            end
          end
        else
          if ci.product.free_shipping
            next
          end
          case carrier
          when "UPS"
            p += ups_quote(zip, ci.product.weight, method) * ci.quantity
          when "DHL"
            p += dhl_quote(zip, ci.product.weight, method) * ci.quantity
          when "FedEX"
            p += fedex_quote(zip, ci.product.weight, method) * ci.quantity
          end
        end
      end
      cart.cart_items.each do |ci|
        if ci.kit
          ci.kit.products.each do |product|
            weight = product.weight
            if between?(weight, 20, 50)
              p += 10 * ci.quantity
            elsif between?(weight, 51, 100)
              p += 20 * ci.quantity
            elsif between?(weight, 101, 10000)
              p += 40 * ci.quantity
            end
          end
        else
          weight = ci.product.weight
          if between?(weight, 20, 50)
            p += 10 * ci.quantity
          elsif between?(weight, 51, 100)
            p += 20 * ci.quantity
          elsif between?(weight, 101, 10000)
            p += 40 * ci.quantity
          end
        end
      end
      return p
    else
      return freight_quote(zip, cart, fq_opts)
    end
  end

  # Generic name for the shipping methods.
  def shipping_methods
    ["Next Day Shipping", "2 Day Shipping","Ground Service"]
  end

  # Asks the UPS site for a quote for a shipping with this data.
  def ups_quote(to_zip, weight, shipping_method)
    params = {
      :zip => to_zip,
      :sender_zip => 75042,     # TPD's headquarters
      :weight => weight,
      :ups_license_number => "3C0E386CDB8EC368",
      :ups_user => "printerdepot",
      :ups_password => "ford07"
    }

    shipping = Shipping::UPS.new(params)
    shipping.service_type = UPSMethods.invert[shipping_method]
    shipping.price
  end

  def dhl_quote(to_zip, weight, shipping_method)
    d = ShippingCalc::DHL.new

    opts = {
      :api_user => "PRINT_4126",
      :api_password => "6296G82KU9",
      :shipping_key => "54233F2B2C4E5D41455B56545752305043485142445A535F54",
      :account_num => "783055820",
      :date => Time.now + 86400,
      :service_code => DHLMethods.invert[shipping_method],
      :shipment_code => "P",
      :weight => (weight).to_i,
      :to_zip => to_zip.to_i,
      :to_state => Shipping::Base.state_from_zip(to_zip)
    }
    begin
      quote = d.quote(opts)
    rescue Exception
      return 0.to_f
    end
    quote
  end

  def fedex_quote(zip, weight, method)
    q = (ups_quote(zip, weight, method) + dhl_quote(zip, weight, method)) / 2.0
    round(q)
  end

  def freight_quote(to_zip, weight, conditions)
    opts = {
      :api_email => "xmltest@FreightQuote.com",
      :api_password => "xml",
      :from_zip => 75042,
      :to_zip => to_zip,
      :weight => weight,
      :class => "92.5"
    }

    if !conditions.nil?
      conditions[:liftcharge] == "true" ?  (opts[:liftcharge] = true) : (opts[:liftcharge] = false)
      conditions[:inside_delivery] == "true" ? (opts[:inside_delivery] = true) : (opts[:inside_delivery] = false)
    end
    f = ShippingCalc::FreightQuote.new
    quotes = f.quote(opts)
    return quotes
  end

  def round(f)
    s = f.to_s
    if (s =~ /(\d+\.\d?\d?)\d*/)
      return $1
    else
      raise StandardError.new("Error rounding")
    end
  end

  def between?(val,a,b)
    val >= a && val <= b
  end
end
