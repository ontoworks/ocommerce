#!/usr/bin/ruby -w
# simple.rb - simple MySQL script using Ruby MySQL module

require "mysql"

begin
  # connect to the MySQL server
  dbh_tpd = Mysql.real_connect("localhost", "root", "s4ntiag0", "tpd")
  dbh_new = Mysql.real_connect("localhost", "root", "s4ntiag0", "tpd_development")

  orders = dbh_tpd.query("SELECT * FROM orders")

  orders.each_hash do |o|
    dbh_new.query("UPDATE orders SET telephone = \"#{o['customers_telephone']}\", email_address=\"#{o['customers_email_address']}\" WHERE id=#{o['orders_id']}")
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
