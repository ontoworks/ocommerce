ActionController::Routing::Routes.draw do |map|
  map.resources :discounts
  map.resources :categories
  map.resources :warranties
  map.resources :coupons
  map.resources :brands

  ##
  ## ROUTES FOR UI
  ##
  map.connect "ui/:type/:view/:id", :controller => "ui", :action => "ui_proxy"


  ##
  ## ROUTES FOR USERS
  ##
  map.connect "users/:id/password_new", :controller => "users", :action => "password_new"

  map.connect "users/password_forgotten", :controller => "users", :action => "password_forgotten",
              :conditions => {:method => :get}

  map.connect "users/:id/orders/:order_id", :controller => "users", :action => "show_order",
              :conditions => {:method => :get}

  map.connect "users/:id/orders", :controller => "users", :action => "orders",
              :conditions => {:method => :get}


  ##
  ## ROUTES FOR ORDERS
  ##
  map.connect "orders/stats/totals", :controller => "orders", :action => "all_totals",
              :conditions => {:method => :get}

  map.connect "orders/:id/status/:status", :controller => "orders", :action => "status",
              :conditions => {:method => :put}

  map.connect "orders/:id/tracking_code", :controller => "orders", :action => "tracking_code",
              :conditions => {:method => :post}

  map.connect "orders/:id/invoice", :controller => "orders", :action => "invoice",
              :conditions => {:method => :get}

  map.connect "orders/:id/comments", :controller => "orders", :action => "comments",
              :conditions => {:method => :post}

  map.resources :orders do |orders|
    orders.resources :order_items
  end



  map.resources :users, :collection => { :save_cell => :post, :draft => :post }
  map.resources :shipping, :collection => { :options => :get }


  ##
  ## ROUTES FOR PRODUCTS
  ##
  map.connect "products/:id/hot/:value", :controller => "products", :action => "as_hot",
              :conditions => {:method => :put}

  map.connect "products/:id/hot/:value", :controller => "products", :action => "freight",
              :conditions => {:method => :put}

  map.connect "products/:id/free_shipping/:value", :controller => "products", :action => "as_free_shipping",
              :conditions => {:method => :put}

  map.connect "products/search", :controller => "products", :action => "search"

  map.connect "products/marketing", :controller => "products", :action => "marketing"

  map.connect "products/marketing/marketplace-feed-generator", :controller => "products", :action => "feed_generator"

  map.connect "products/search_by/:filter/:value", :controller => "products", :action => "search_by",
              :conditions => {:method => :get}

  map.connect "products/:id/cross_sells/:product_id", :controller => "products", :action => "remove_cross_sell",
              :conditions => {:method => :delete}

  map.connect "products/:id/cross_sellers/:product_id", :controller => "products", :action => "remove_cross_seller",
              :conditions => {:method => :delete}

  map.connect "products/:id/warranties/:warranty_id", :controller => "products", :action => "add_warranty",
              :conditions => {:method => :post}

  map.connect "products/:id/warranties/:warranty_id", :controller => "products", :action => "remove_warranty",
              :conditions => {:method => :delete}

  map.connect "products/:id/warranties", :controller => "products", :action => "warranties"

  map.connect "products/:id/subscriptions", :controller => "products", :action => "subscriptions"

  map.connect "products/:product_id/category/:id", :controller => "products", :action => "set_category",
              :conditions => {:method => :post}

  # SPECS
  map.connect "products/:id/desc/:field", :controller => "products", :action => "save_specs_field",
              :conditions => {:method => :put}

  map.connect "products/:id/desc", :controller => "products", :action => "specs",
              :conditions => {:method => :get}

  map.connect "products/:id/prices", :controller => "products", :action => "prices"

  map.connect "products/:id/kits/:kit_type", :controller => "products", :action => "add_kit",
              :conditions => {:method => :post}

  map.connect "products/:id/kits", :controller => "products", :action => "kits"

  map.resources :products, :collection => { :save_cell => :post, :draft => :post,
                                            :categories => :get, :cross_sells => :post,
                                            :cross_sellers => :post, :image => :get,
                                            :save_product_info => :post, :upload_image => :post,
                                            :save_prices_list => :post, :save_product_specs => :post,
                                            :brand => :get }

  ##
  ## ROUTES FOR KITS
  ##
  map.connect "kits/:id/image", :controller => "kits", :action => "show_image",
              :conditions => {:method => :get}

  map.connect "kits/:id/image", :controller => "kits", :action => "upload_image",
              :conditions => {:method => :post}

  map.connect "kits/:id/products/:product_id", :controller => "kits", :action => "add_product",
              :conditions => {:method => :put}

  map.connect "kits/:id/products/:product_id", :controller => "kits", :action => "del_product",
              :conditions => {:method => :delete}

  map.connect "kits/:id/products", :controller => "kits", :action => "products"

  map.connect "kits/:id/price", :controller => "kits", :action => "update_price",
              :conditions => {:method => :post}

  ##
  ## ROUTES FOR CARTS
  ##
  map.connect "cart/products/:product_id", :controller => "cart", :action => "remove_product",
      :conditions => {:method => :delete}

  map.step1 "/cart/step1", :controller => "cart", :action => "login"
  map.step2 "/cart/step2", :controller => "cart", :action => "customer_info"
  map.step3 "/cart/step3", :controller => "cart", :action => "shipping"
  map.step4 "/cart/step4", :controller => "cart", :action => "final_confirmation"

  map.resources :home

  map.checkout "/checkout", :controller => "cart", :action => "checkout"

#  map.resources :cart, :collection => { :home => :get }

  # The priority is based upon order of creation: first created -> highest priority.
  map.checkout "/checkout", :controller => "cart", :action => "checkout"

  map.resource :session

  map.root :controller => "home"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
