require 'google4r/checkout'

# These module contains all the payment gateways used by the
# application. Currently it works with Paypal through the "paypal" gem, with
# Google Checkout through the "google4r-checkout" gem and a home-grown direct
# billing system.
module Gateways

  # Handles all the tax tables that Google will use when applying taxes to
  # each product during their checkout. 
  class TaxTableFactory
    # Returns an unidimensional array with a table containing all the tax
    # rules for every state supplied by the "States" table. Currently, it
    # only supports US states. The time parameter is needed by the
    # google4r-checkout gem but it's not used in this table generator.
    def effective_tax_tables_at(time)
      table = Google4R::Checkout::TaxTable.new(false)
      table.name = "Tax Table"
      states = State.find(:all)
      states.each do |state|
        table.create_rule do |rule|
          rule.area = Google4R::Checkout::UsStateArea.new(state.short_name)
          rule.rate = state.tax
        end
      end
      [table]
    end
  end

  # === Introduction
  # This class handles all the processing for Google Checkout. Since this
  # gateway is so different to the ones covered in ActiveMerchant, everything
  # is handled apart. The gateway's based on the gem "google4r-checkout".
  # TaxTableFactory defines a generator for TaxTables that works according to
  # Google's specification. Currently, the time parameter's not used.
  # 
  # GoogleGateway abstracts all the nasty stuff that happens below in
  # google4r-checkout.
  #
  # TaxTableFactory depends on the existance of a States table with the taxes
  # for each state.
  #
  # All the parameterse needed to connect to Google's servers are obtained from
  # the global variables:
  # * $google_merchant_id
  # * $google_merchant_key
  #
  # 
  # === Usage
  #
  # This is the minimum number of steps needed to connect to Google's servers:
  #    gateway = Gateways::GoogleGateway.new
  #    gateway.add_shipping_method(Google4R::Checkout::FlatRateShipping, "Some Shipping Method", 49.99)
  #    gateway.add_items_to_cart(some_cart_items)
  #    redirect_to gateway.checkout_uri
  #
  # === Authors
  # * Federico Builes  (mailto:federico.builes@gmail.com)
  class GoogleGateway

    attr_accessor :frontend, :command

    # TODO: Cambiar de Sandbox true a false
    #
    # Creates a new Gateway to communicate to Google. If use_sandbox is true
    # it'll connect to the sandbox, if not, it will connect to the live
    # servers. Defaults to true.
    def initialize(use_sandbox=true)
      config = {:merchant_id => $google_merchant_id, :merchant_key => $google_merchant_key, :use_sandbox => use_sandbox }
      
      @frontend = Google4R::Checkout::Frontend.new(config)
      set_taxes
      @command = @frontend.create_checkout_command
    end
    
    # Adds a shipping method to the order. The field method is one of Google's
    # supported shipping methods (e.g. FlatRateShipping). It also receives
    # the name that will be shown to the user and the price of it.
    def add_shipping_method(method, name, price)
      @command.create_shipping_method(method) do |sm|
        sm.name = name 
        sm.price = Money.new(price * 100, "USD")
        sm.create_allowed_area(Google4R::Checkout::WorldArea)
      end
    end
    
    # Adds a collection of items to the order's shopping cart. Currently, it
    # uses a Cart object that has many cart_items. Each one of these items
    # has a:
    # * name
    # * description
    # * unit_price
    # * quantity
    # The final price of the order will be represented by a Money object (http://dist.leetsoft.com/api/money)
    def add_items_to_cart(cart)
      cart.cart_items.each do |item|
        @command.shopping_cart.create_item do |i|
          i.name = item.name
          i.description = ""
          i.unit_price = Money.new(item.product_price * 100, "USD")
          i.quantity = item.quantity
        end
      end
    end
    
    # Returns the checkout URI that the user should use to finalize the
    # order:
    #    g = GoogleGateway.new
    #    ...
    #    redirect_to g.checkout_uri
    def checkout_uri            # TODO cambiar por direccion real
      @command.continue_shopping_url = "http://200.116.131.110:3000/cart/step2"
      response = @command.send_to_google_checkout.redirect_url    
    end

    private

    def set_taxes
      @frontend.tax_table_factory = TaxTableFactory.new
    end
  end
end
