# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 73) do

  create_table "applied_discounts", :force => true do |t|
    t.integer  "order_id"
    t.integer  "discount_id"
    t.float    "price_off"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "discount_type"
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total",         :precision => 8,  :scale => 2
    t.decimal  "product_price", :precision => 15, :scale => 4
    t.integer  "warranty_id"
    t.integer  "kit_id"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discount_id"
    t.float    "discount_price"
  end

  create_table "categories", :force => true do |t|
    t.string   "text"
    t.text     "description"
    t.string   "image"
    t.integer  "parent_id"
    t.boolean  "status",        :default => true
    t.integer  "sort_order"
    t.string   "heading_title"
    t.string   "mkeywords"
    t.string   "mdescript"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_products", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "content_containers", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents", :force => true do |t|
    t.string   "name"
    t.text     "text"
    t.string   "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_container_id"
  end

  create_table "coupons", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.date     "date_up"
    t.date     "date_down"
    t.integer  "use_times"
    t.integer  "order_total_up"
    t.integer  "order_total_low"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "value"
    t.decimal  "price_off",       :precision => 8, :scale => 2
    t.decimal  "percent_off",     :precision => 4, :scale => 2
  end

  create_table "coupons_users", :id => false, :force => true do |t|
    t.integer "coupon_id"
    t.integer "user_id"
  end

  create_table "cross_sells", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "cross_sell_product_id"
    t.integer "cs_position"
  end

  create_table "discounts", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "discount_by"
    t.float    "value"
    t.date     "date_up"
    t.date     "date_down"
    t.float    "min_price"
    t.float    "max_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "use_times"
  end

  create_table "kit_items", :force => true do |t|
    t.integer  "kit_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kits", :force => true do |t|
    t.integer  "product_id"
    t.integer  "type_id"
    t.integer  "price_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kit_type"
    t.string   "image"
    t.integer  "order"
    t.decimal  "price",      :precision => 6, :scale => 2
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.string   "product_name"
    t.string   "product_model"
    t.decimal  "product_price", :precision => 8, :scale => 2
    t.string   "final_price"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "warranty_id"
    t.integer  "kit_id"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "company"
    t.string   "street_address"
    t.string   "suburb"
    t.string   "city"
    t.string   "postcode"
    t.string   "state"
    t.string   "country"
    t.string   "telephone"
    t.string   "email_address"
    t.string   "delivery_name"
    t.string   "delivery_company"
    t.string   "delivery_street_address"
    t.string   "delivery_suburb"
    t.string   "delivery_city"
    t.string   "delivery_postcode"
    t.string   "delivery_state"
    t.string   "delivery_country"
    t.string   "billing_name"
    t.string   "billing_company"
    t.string   "billing_street_address"
    t.string   "billing_suburb"
    t.string   "billing_city"
    t.string   "billing_postcode"
    t.string   "billing_state"
    t.string   "billing_country"
    t.string   "payment_method"
    t.string   "cc_type"
    t.string   "cc_owner"
    t.string   "cc_number"
    t.string   "cc_expires"
    t.string   "cvvnumber"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "shipping_method"
    t.decimal  "shipping_total",          :precision => 15, :scale => 4
    t.integer  "gateway_order_number"
    t.string   "carrier"
    t.float    "shipping_approx"
    t.string   "tracking_code"
    t.float    "taxes"
    t.text     "comments"
    t.text     "front_comment"
    t.string   "coupon"
    t.integer  "freight_options"
    t.integer  "freight_ship_to"
    t.integer  "discount_id"
    t.float    "discount_price"
  end

  create_table "prices", :force => true do |t|
    t.integer  "product_id"
    t.decimal  "price",      :precision => 15, :scale => 4
    t.string   "context"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity"
  end

  create_table "product_descriptions", :force => true do |t|
    t.integer  "product_id"
    t.text     "specs"
    t.text     "features"
    t.text     "includes"
    t.text     "warranty"
    t.text     "overview"
    t.text     "features_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "model"
    t.string   "condition"
    t.string   "image"
    t.string   "status"
    t.integer  "brand_id"
    t.decimal  "width",         :precision => 6, :scale => 2
    t.decimal  "weight",        :precision => 6, :scale => 2
    t.decimal  "height",        :precision => 6, :scale => 2
    t.decimal  "length",        :precision => 6, :scale => 2
    t.integer  "times_ordered"
    t.integer  "times_viewed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_hot"
    t.boolean  "free_shipping"
    t.integer  "category_id"
    t.string   "marketplaces"
  end

  add_index "products", ["name", "model"], :name => "FULLTEXT_NAME_MODEL"

  create_table "products_warranties", :id => false, :force => true do |t|
    t.integer "warranty_id"
    t.integer "product_id"
  end

  create_table "promotions", :force => true do |t|
    t.string   "title"
    t.date     "start"
    t.date     "end"
    t.integer  "type_id"
    t.integer  "category_id"
    t.integer  "product_id"
    t.integer  "price_id"
    t.integer  "banner_id"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percent"
    t.integer  "price_off"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipping_modules", :force => true do |t|
    t.string   "name"
    t.integer  "from_weight"
    t.integer  "upto_weight"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_options", :force => true do |t|
    t.integer  "shipping_module_id"
    t.string   "option"
    t.boolean  "active"
    t.boolean  "international"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "full_name"
    t.string   "short_name"
    t.float    "tax"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "types", :force => true do |t|
    t.string   "text"
    t.string   "classname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "usergroup",                              :default => "customer", :null => false
    t.string   "company"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.string   "country"
    t.string   "telephone"
    t.string   "crypted_password"
    t.string   "firstname",                              :default => "",         :null => false
    t.string   "lastname",                               :default => "",         :null => false
    t.string   "salt",                      :limit => 2
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "warranties", :force => true do |t|
    t.string   "title"
    t.string   "context"
    t.integer  "product_id"
    t.integer  "category_id"
    t.decimal  "price",       :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
