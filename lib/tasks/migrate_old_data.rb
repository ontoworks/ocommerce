#!/usr/bin/ruby -w
# simple.rb - simple MySQL script using Ruby MySQL module

require "mysql"

begin
  def status(s)
    case s
      when "3", "102", "104"
      2
      when "4", "5", "103", "105"
      3
      else
      1
    end
  end

  def find_carrier(sm)
    case sm
    when /federal/i
      "Fedex"
    when /dhl/i
      "DHL"
    when /parcel/i
      "UPS"
    when /free/i
      "Free"
    when /freight/i
      "Freight"
    else
      "Unknown"
    end
  end

  def find_warranty(dbh_new, old_warranty, old_price)
    warranty = "NULL"
    if old_warranty.downcase =~ /year/
      title = "#{old_warranty} $#{old_price.to_f.round} - Old TPD"
      id = dbh_new.query("SELECT id FROM warranties WHERE title=\'#{title}\'")
      if id.num_rows > 1
        id.each do |id|
          warranty = id
        end
      else
        insert_warranty = dbh_new.query("INSERT INTO warranties SET title=\'#{title}\',price=#{old_price}, context=\'old\'")
        warranty = dbh_new.insert_id
      end
    end
    warranty
  end

  def tracking_codes
  end

  # connect to the MySQL server
  dbh_tpd = Mysql.real_connect("localhost", "root", "s4ntiag0", "tpd")
  dbh_new = Mysql.real_connect("localhost", "root", "s4ntiag0", "tpd_development")

  dbh_new.query("TRUNCATE TABLE orders")
  dbh_new.query("TRUNCATE TABLE order_items")
  dbh_new.query("DELETE FROM warranties WHERE context='old'")

  orders = dbh_tpd.query("SELECT * FROM orders")

  orders.each_hash do |o|
    totals = dbh_tpd.query("SELECT * FROM orders_total WHERE orders_id=#{o['orders_id']}")
    @shipping_method = "NULL"
    @carrier = "NULL"
    @shipping_approx = "NULL"
    totals.each_hash do |t|
      if t['class'] =~ /ot_shipping/
        @shipping_method = t['title'] || "NULL"
        @carrier = find_carrier(t['title'])
        @shipping_approx = t['value']
      end
    end

    tracking_code = ""
    ["ups_track_num","ups_track_num2","ups_track_num3","usps_track_num","usps_track_num2",
     "usps_track_num3","fedex_track_num","fedex_track_num2","fedex_track_num3"].each do |code|
      if !(o[code].nil? || o[code] =~ /$\s*^/)
        tracking_code << "#{o[code]}, "
      end
    end
    tracking_code = tracking_code == "" ? "NULL" : "\"#{tracking_code}\""

    puts tracking_code

    insert_order = dbh_new.query("INSERT INTO orders SET
        id = \"#{o['orders_id']}\",
        user_id = \"#{o['customers_id']}\",
        name = \"#{dbh_new.quote(o['customers_name'])}\",
        delivery_name = \"#{dbh_new.quote(o['delivery_name'])}\",
        delivery_company = \"#{dbh_new.quote(o['delivery_company'])}\",
        delivery_street_address = \"#{dbh_new.quote(o['delivery_street_address'])}\",
        delivery_suburb = \"#{dbh_new.quote(o['delivery_suburb'])}\",
        delivery_city = \"#{dbh_new.quote(o['delivery_city'])}\",
        delivery_postcode = \"#{o['delivery_postcode']}\",
        delivery_state = \"#{o['delivery_state']}\",
        delivery_country = \"#{o['delivery_country']}\",
        billing_name = \"#{dbh_new.quote(o['billing_name'])}\",
        billing_company = \"#{dbh_new.quote(o['billing_company'])}\",
        billing_street_address = \"#{dbh_new.quote(o['billing_street_address'])}\",
        billing_suburb = \"#{dbh_new.quote(o['billing_suburb'])}\",
        billing_city = \"#{dbh_new.quote(o['billing_city'])}\",
        billing_postcode = \"#{o['billing_postcode']}\",
        billing_state = \"#{o['billing_state']}\",
        billing_country = \"#{o['billing_country']}\",
        payment_method = \"#{o['payment_method'].downcase}\",
        cc_type = \"#{o['cc_type']}\",
        cc_owner = \"#{o['cc_owner']}\",
        cc_number = \"#{o['cc_number']}\",
        cc_expires = \"#{o['cc_expires']}\",
        cvvnumber = \"#{o['cvvnumber']}\",
        created_at = \"#{o['date_purchased']}\",
        status = \"#{status(o['orders_status'])})\",
        carrier = \"#{@carrier}\",
        shipping_method = \"#{dbh_new.quote(@shipping_method)}\",
        shipping_approx = #{@shipping_approx},
        tracking_code = #{tracking_code}
    ")
#        orders_date_finished = \"#{o['orders_date_finished']}\",
#        purchase_order_number = \"#{o['purchase_order_number']}\"


    products = dbh_tpd.query("SELECT * FROM orders_products WHERE orders_id=#{o['orders_id']}")

    @taxes = "NULL"
    products.each_hash do |p|
      @taxes = p['products_tax'].to_f/100

      @warranty = "NULL"
      attrs = dbh_tpd.query("SELECT * FROM orders_products_attributes WHERE orders_id=#{p['orders_id']} AND orders_products_id=#{p['orders_products_id']}")
      attrs.each_hash do |a|
        @warranty = find_warranty(dbh_new, a["products_options_values"], a["options_values_price"])
      end

      insert_order_item = dbh_new.query("INSERT INTO order_items SET
        order_id = #{p['orders_id']},
        product_id = #{p['products_id']},
        product_model = \"#{p['products_model']}\",
        product_name = \"#{dbh_new.quote(p['products_name'])}\",
        product_price = \"#{p['products_price']}\",
        final_price = \"#{p['final_price']}\",
        quantity = #{p['products_quantity']},
        warranty_id = #{@warranty}
      ")
    end

    update_taxes = dbh_new.query("UPDATE orders SET taxes=#{@taxes} WHERE id=#{o['orders_id']}")
  end
  orders.free

rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
ensure
  # disconnect from server
  dbh_tpd.close if dbh_tpd
  dbh_new.close if dbh_new
end
