class ProductsController < ApplicationController
  require 'lib/feeds'
  require 'will_paginate'

  before_filter(:pagination)
  before_filter(:sort)
  before_filter(:ui_stuff)
#  before_filter(:load_session)

  skip_before_filter :verify_authenticity_token

  layout "home", :except => [:image, :prices, :save_product_info, :specs,
                             :save_product_specs, :marketing, :generate_feeds_for_marketplaces]



  # GET /products/search?query="search string"
  def search
    if !params[:query].nil?
      @products = Product.paginate_like(params[:query], "name", "ASC", @limit, params[:page])
    end
  end

  # GET /products
  # GET /products.xml
  def index
    if !params[:query].nil?
      @products = Product.find_like(params[:query], false) #, "name", "ASC", @limit)
      @total_count = Product.count_by_like(params[:query], false)
    else
      @products = Product.find(:all, :offset => @offset, :limit => @limit,
                               :order => @sort.to_s+" "+@order.to_s)
      @total_count = Product.count
    end

    if !params[:category_id].nil?
      category = Category.find(params[:category_id])
      @products = category.products.find(:all, :offset => @offset, :limit => @limit)
      @total_count = category.products.count
    end

    @products_xml = @products.to_xml(:methods => [:customer_price, :business_price,
        :wholesale_price, :length1]) do |xml|
      xml.totalCount(@total_count)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products_xml }
      format.json  { render :json => {:products => @products } }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    load_session

    @product = Product.find(params[:id])
    @product_desc = @product.product_description

    # Build XML resposne object
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.response << @product.to_xml

    respond_to do |format|
      format.html # { render :layout => 'home' }
      format.xml  # { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        flash[:notice] = 'Product was successfully created.'
        format.html { redirect_to(@product) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        flash[:notice] = 'Product was successfully updated.'
        format.html { redirect_to(@product) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end

  ##
  ## CUSTOM METHODS // Deben ir sobre el modelo
  ##
  # PUT /products/:id/hot/:value
  def as_hot
    @product = Product.find(params[:id])
    @saved = @product.update_attribute("is_hot", params[:value])
    respond_to do |format|
      format.xml { render :xml => @saved }
    end
  end
  # PUT /products/:id/free_shipping/:value
  def as_free_shipping
    @product = Product.find(params[:id])
    @product.update_attributes({:free_shipping => params[:value]})
  end
  # PUT /products/:id/freight/:value
  def freight
    @product = Product.find(params[:id])
    @saved = @product.update_attribute("freight", params[:value])
    respond_to do |format|
      format.xml { render :xml => @saved }
    end
  end


  # POST /products/1/category/2
  # Set this product's category to Category with id 2
  def set_category
    @product = Product.find(params[:product_id])
    # @product.categories.delete_all
    @product.category=Category.find(params[:id])
    @product.save
  end

  # GET /products/search_by/:filter/:value
  def search_by
    session[:search_by] ||= {}

    case params[:filter]
    when "category"
      session[:search_by][:category] = params[:value]
      session[:search_by][:category] = nil if params[:value] == "none"
    when "brand"
      session[:search_by][:brand] = params[:value]
      session[:search_by][:brand] = nil if params[:value] == "none"
    when "condition"
      session[:search_by][:condition] = params[:value]
      session[:search_by][:condition] = nil if params[:value] == "none"
    when "price"
      session[:search_by][:price] = params[:value]
      session[:search_by][:price] = nil if params[:value] == "none"
    else
    end

    query = search_query
    if query.nil?
      redirect_to :controller => "home"
    else
      @products = Product.paginate_by_sql query, :page => params[:page], :per_page => 16
      session[:search_by][:filter_has_results] = true
      if @products.empty?
        session[:search_by][:filter_has_results] = false
      end
    end
  end

  def search_query
    @query = "SELECT products.* "
    @from = "FROM products, "
    @where = " WHERE "

    @filters_exist = false

    if !session[:search_by][:brand].nil?
      @where += "products.brand_id = "+session[:search_by][:brand]+" AND"
      @filters_exist = true
    end
    if !session[:search_by][:category].nil?
      @from += "categories_products, "
      @where += " categories_products.product_id = products.id AND categories_products.category_id="+session[:search_by][:category]+" AND"
      @filters_exist = true
    end
    if !session[:search_by][:condition].nil?
      @where += " products.condition = '#{session[:search_by][:condition]}' AND"
      @filters_exist = true
    end
    if !session[:search_by][:price].nil?
      @from += "prices, "

      @price_range = session[:search_by][:price].split(/to/)

      @where += " prices.product_id = products.id AND prices.context = 'default' AND"
      @where += " prices.price >= #{@price_range[0]} AND prices.price <= #{@price_range[1]} AND"
      @filters_exist = true
    end

    session[:search_by][:filters_exist] = @filters_exist

    if @filters_exist
      @from = @from.to(@from.length-3)
      @query += @from+@where+" status='Y'"
#      @query.to(@query.length-4)+" AND status='Y'"
    else
      nil
    end
  end


  # POST /products/save_cell?id=&field=&value=
  def save_cell
      field = params[:field].gsub(/\-/, "_")

      Product.update(params[:id], { field => params[:value]})
      @product = Product.find(params[:id])
      respond_to_save
  end

  # POST /products/draft
  def draft
    product = Product.new(:status => "D",
                           :name => "Enter Product Name",
                           :description => "Enter Description",
                           :image => "add_new.png",
                           :model => "Enter Model",
                           :condition => "New",
                           :weight => 0,
                           :width => 0,
                           :length => 0,
                           :height => 0)
    product.save
    product.update_attribute(params[:field], params[:value])

    product.brand=Brand.find(6) # HP as default. To config.
    product.categories << Category.find(1000)

    product.save

    respond_to do |format|
      format.xml { render :xml => product.to_xml( :only => :id ) }
    end
  end

  # GET /products/brand/:id
  def brand
    @brand = Brand.find(params[:id])
    @products = @brand.products.paginate :all, :page => params[:page],
         :per_page => 16
  end

  # GET /products/:id/specs
  def specs
    @product = Product.find(params[:id])
    @specs = @product.product_description
    if @specs.nil?
      @specs = ProductDescription.new({:product_id => params[:id]})
      @specs.save
    end
    respond_to do |format|
       format.xml
    end
  end

  # POST /products/:id/warranties
  def warranties
    @product = Product.find(params[:id])
    @warranties = @product.warranties
    respond_to do |format|
      format.xml { render :xml => @warranties }
    end
  end

  # POST /products/:id/warranties/:warranty_id
  def add_warranty
    @product = Product.find(params[:id])
    @product.warranties << Warranty.find(params[:warranty_id])
    respond_to do |format|
      format.xml { render :xml => @product.to_xml(:only => :id) }
    end
  end

  # DELETE /products/:id/warranties/:warranty_id
  def remove_warranty
    @product = Product.find(params[:id])
    @product.warranties.delete(Warranty.find(params[:warranty_id]))
    respond_to do |format|
      format.xml { render :xml => @product.to_xml(:only => :id) }
    end
  end

  # POST /products/:id/kits/:kit_type
  def add_kit
    @order = {"platinum" => 1, "gold" => 2, "silver" => 3}

    @product = Product.find(params[:id])
    @kit = Kit.new({:kit_type => params[:kit_type], :order => @order[params[:kit_type]]})
    @product.kits << @kit
    respond_to do |format|
      format.xml { render :xml => @kit.to_xml(:only => :id) }
    end
  end

  def category
    @category = Category.find(params[:id])
#    @products = @category.products
#    @count = @category.products.count

    @products = @category.products.paginate :all,
       :conditions => ["status=?", 'Y'],
       :page => params[:page],
       :per_page => 16
  end

  def categories
    @node = params[:node]
    if (@node == "source")
      @node = 1000
    end

    @root = Category.find(@node)
#    @root = Category.find(:first, :conditions => ["parent_id = ?", 0])
    @category_tree = @root.children
    respond_to do |format|
      format.json { render :json => @category_tree.to_json(:only => [:id, :text])  }
    end
  end

  def cross_sell_products
    @product = Product.find(params[:id])
    @cross_sells = @product.cross_sell_products.find(:all, :conditions => ["status=?", "Y"])

    respond_to do |format|
      format.xml { render :xml => @cross_sells.to_xml(:methods => [:cross_sell_group],
                                                       :only => [:cross_sell_product_id, :name, :model] )}
    end
  end

  def cross_seller_products
    @product = Product.find(params[:id])
    @cross_sellers = @product.cross_seller_products.find(:all, :conditions => ["status=?", "Y"])

    respond_to do |format|
      format.xml { render :xml => @cross_sellers.to_xml(:methods => [:cross_sell_group],
                                                         :only => [:product_id, :name, :model]) }
    end
  end

  def cross_sells
    @product = Product.find(params[:id])
    @xs = Product.find(params[:product_id])

    @exists_xs = @product.cross_seller_products.find(:first,
      :conditions => ["product_id = ? AND cross_sell_product_id = ?", params[:product_id], params[:id]])

    if !@exists_xs.nil?
      @product.cross_seller_products.delete(@xs)
    end

    @product.cross_sell_products << @xs

    respond_to do |format|
      format.xml { render :xml => @product.to_xml(:only => :id)}
    end
  end

  # DELETE /products/:id/cross_sells/:product_id
  def remove_cross_sell
    @product = Product.find(params[:id])
    @xs = Product.find(params[:product_id])
    @product.cross_sell_products.delete(@xs)
  end

  # DELETE /products/:id/cross_sells/:product_id
  def remove_cross_seller
    @product = Product.find(params[:id])
    @xs = Product.find(params[:product_id])
    @product.cross_seller_products.delete(@xs)
  end

  def cross_sellers
    @product = Product.find(params[:id])
    @xs = Product.find(params[:product_id])

    @exists_xs = @product.cross_sell_products.find(:first,
      :conditions => ["product_id = ? AND cross_sell_product_id = ?", params[:id], params[:product_id]])

    if !@exists_xs.nil?
      @product.cross_sell_products.delete(@xs)
    end

    @product.cross_seller_products << @xs

    respond_to do |format|
      format.xml { render :xml => @product.to_xml(:only => :id)}
    end
  end

  def cross_sells_and_cross_sellers
    @product = Product.find(params[:id])
    @cross_sells = @product.cross_sell_products
    @cross_sellers = @product.cross_seller_products

    @products = @cross_sells+@cross_sellers

    respond_to do |format|
      format.xml { render :xml => @products.to_xml(:only => [:id, :name, :model], :methods => [:cross_sell_group])}
    end
  end

  def save_cross_sell
  end

  def image
    @product = Product.find(params[:id])
  end

  def save_prices_list
    @product = Product.find(params[:id])
    @product.customer_price=params[:customer]
    @product.business_price=params[:business]
    @product.wholesale_price=params[:wholesale]
  end

  def prices
    @product = Product.find(params[:id])

    @customer_price = @product.customer_price
    @business_price = @product.business_price || @customer_price
    @wholesale_price = @product.wholesale_price || @customer_price

    respond_to do |format|
      format.xml
    end
  end

  def kits
    @kits = Kit.find(:all, :conditions => ["product_id = ?", params[:id]], :order => "`order`")
    respond_to do |format|
      format.xml {render :xml => @kits}
    end
  end

  def categories_list
    Category.find(:all)
  end

  def upload_image
    @product = Product.find(params[:id])
    @product.save_image(params)
    respond_to do |format|
      format.xml { render :xml => @product }
    end
  end

  def save_product_info
    @product = Product.find(params[:id])
    @product.update_attributes({
      :status => status_id(params[:status]),
      :name => params[:name],
      :height => params[:height],
      :weight => params[:weight],
      :width => params[:width],
      :description => params[:description],
      :model => params[:model],
      :condition => params[:condition],
      :brand_id => brand_id(params[:brand]),
      :length => params[:length1]
    })
  end

  def save_product_specs
    @specs = ProductDescription.find_by_product_id(params[:id])
    @specs.update_attributes({
       :specs => params[:specs],
       :features => params[:features],
       :includes => params[:includes],
       :warranty => params[:warranty],
       :overview => params[:overview],
       :features_desc => params[:features_desc]
    })
  end


  # PUT /product/:id/specs/:field
  def save_specs_field
    @product = Product.find(params[:id])
    case params[:field]
    when "main_info"
      @product.update_attribute("description", params[:value])
    else
      @product.product_description.update_attribute(params[:field], params[:value])
    end
  end

  def subscriptions
    p=Product.find(params[:id])
    if (params[:state]=="true")
      p.subscribe(params[:service])
    elsif (params[:state]=="false")
      p.unsubscribe(params[:service])
    end
    respond_to do |format|
      format.xml { render :xml => "" }
    end
  end

  def marketing
  end

  # POST /products/marketing/marketplace-feed-generator
  def feed_generator
    debugger
    @products = []
    Product.find(:all, :conditions => ["status = ?", "Y"]).each do |p|
      if !p.category.nil?
        case p.category.id
        when 1,10,12,14,16,217
          @products << p
        else
        end
      end
    end
    nextag
    pricegrabber
    shopzilla
    system("zip -r /tmp/feeds.zip /tmp/nextagfeed.txt /tmp/UploadToPriceGrabberJanuary3.txt /tmp/shopzilla_feed.txt")
    send_file("/tmp/feeds.zip")
#    redirect_to :action => "marketing"
  end

  # private respond_to_save
  private
  # Resolve status to its internal id
  def status_id(status)
    case status
    when "Active"
      "Y"
    when "Inactive"
      "N"
    when "Draft"
      "D"
    else
      "N"
    end
  end

  # Resolve brand to its internal id
  def brand_id(brand_name)
    Brand.find_by_name(brand_name).id
  end

  def respond_to_save
    # Build XML resposne object
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.product {
      xml.id(@product.id, :id => "id")
    }

    respond_to do |format|
      format.xml { render :xml => xml }
#      format.xml { render :xml => @product.to_xml ( :only => :id ) }
    end
  end

  def pagination
    @offset = 0
    @limit = 20
    if params[:offset] && params[:limit]
      @offset = params[:offset]
      @limit = params[:limit]
    end
  end

  def sort
    @sort = "times_viewed"
    @order = "DESC"
    if params[:sort] && params[:order]
      @sort = params[:sort]
      @order = params[:order]
    end
  end

  def ui_stuff
    @cart = find_cart
    @categories = categories_list
    @supplies = Category.find(:all, :conditions => ["parent_id = ?", 210 ])
    @brands = Brand.find(:all)
  end

  def load_session
    session[:search_by] = {}
    session[:checkout] = false
  end
end
