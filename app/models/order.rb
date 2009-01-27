class Order < ActiveRecord::Base

  belongs_to :user
  belongs_to :discount
  has_many :order_items

require 'lib/taxes'


PENDING = 1
COMPLETE = 0
SHIPPED = 2
CANCELLED = 3

PAYMENT_TYPES = [
  ["Google Checkout" ,      "google"],
  ["Paypal" ,               "paypal"],
  ["Credit Card" ,          "direct"]
]

CC_TYPES = [["Mastercard",       "mastercard"],
            ["Visa",             "visa"],
            ["Discover",         "discover"],
            ["JCB",              "jcb"],
            ["Diner's Club",             "diners"]
           ]

FREIGHT_OPTIONS = ["", "Liftcharge", "Inside Delivery", "Liftcharge and Inside Delivery"]
FREIGHT_SHIP_TO = ["", "Residential address", "Business with a dock or a forklift",
                   "Business without a dock or a forklift"
                  ]

  validates_numericality_of :delivery_postcode
  validates_numericality_of :billing_postcode
  validates_length_of :delivery_postcode, :minimum => 4
  validates_length_of :billing_postcode, :minimum => 4

  validates_presence_of :delivery_name, :delivery_street_address,
  :delivery_city, :delivery_postcode, :telephone
  validates_presence_of :billing_name, :billing_street_address,
  :billing_city, :billing_postcode

  validates_inclusion_of :delivery_state, :in => $us_states.keys, :message =>
  "is not valid."

  validates_inclusion_of :billing_state, :in => $us_states.keys,  :message =>
  "is not valid."

  validates_inclusion_of :delivery_country, :in => $countries.values,
  :message => "is not valid."
  validates_inclusion_of :billing_country, :in => $countries.values,
  :message => "is not valid."


  def total
    # revisar que pasa aqui
    #t = totalize_items||0+taxes||0+shipping_approx||0-total_discounts||0
    t = totalize_items+taxes+shipping_approx-total_discounts
#    t ||= 0
    t.round(2)
  end

  def total_discounts
    discount_price || 0
  end

  def totalize_items
    price = 0
    order_items.each do |i|
      # revisar que pasa aqui
      price += i.total
    end
#    self.order_items.sum(&:total)
    price
  end

  def totalize_products
    price = 0
    order_items.each do |i|
      price += i.totalize_product
    end
#    self.order_items.sum { |i| i.totalize_product }
    price.to_f
  end

  def totalize_taxes
    taxes
  end

  def totalize_warranties
    total=0
    order_items.each do |i|
      total += i.totalize_warranty
    end
    total.to_f
  end

  def totalize_promotions
    order_items.sum { |i| i.totalize_promotion }
  end

  def totalize_discounts
    order_items.sum { |i| i.totalize_discounts }
  end

  def current_status
    case self.status
    when Order::PENDING
      "PENDING"
    when Order::COMPLETE
      "COMPLETE"
    when Order::SHIPPED
      "SHIPPED"
    when Order::CANCELLED
      "CANCELLED"
    else
    end
  end

  def date
    self.created_at.to_date
  end

  def validate
    errors.add_to_base "Invalid credit card number" if
      (!cc_number.nil? && cc_number.length < 12)

    errors.add_to_base "Billing State and Country don't match." if
      us_state?(billing_state) && billing_country != "United States"

    errors.add_to_base "Shipping State and Country don't match." if
      us_state?(delivery_state) && delivery_country != "United States"

    errors.add_to_base "Shipping Zip Code doesn't match your state." if
      delivery_postcode.to_s.length > 3 && Shipping::Base.state_from_zip(delivery_postcode) != delivery_state

    errors.add_to_base "Invalid credit card expiration date" if
      (!cc_expires.nil? && (cc_expires =~ /\d\d\/\d\d/) != 0)

    errors.add_to_base "Invalid CVV" if (!cvvnumber.nil? && (cvvnumber.length < 3 || cvvnumber.length > 5))
  end

  def set_freight_options(opts)
    if opts[:liftcharge] && opts[:inside_delivery]
      self.freight_options = 3
    elsif opts[:liftcharge]
      self.freight_options = 1
    elsif opts[:inside_delivery]
      self.freight_options = 2
    else
      self.freight_options = 0
    end
  end

  def set_freight_ship_to(opts)
    case opts
      when nil          then self.freight_ship_to = 0
      when "RES"         then self.freight_ship_to = 1
      when "BIZ_WITH"    then self.freight_ship_to = 2
      when "BIZ_WITHOUT" then self.freight_ship_to = 3
    end
  end

  private

  def us_state?(state)
    $us_states.keys.include?(state)
  end

end
