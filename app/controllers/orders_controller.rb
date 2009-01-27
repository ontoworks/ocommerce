class OrdersController < ApplicationController
  before_filter(:pagination)
  before_filter(:sort)
  before_filter(:date)

  before_filter :admin_only, :only => [:index, :invoice, :show, :create, :update]

  skip_before_filter :verify_authenticity_token

  # GET /orders
  # GET /orders.xml
  def index
    @orders = nil
    @totalCount = 0
    #search by date
    if params[:date] || !params[:query]
      @orders = Order.find(:all,
                           :conditions => ["created_at between ? and ?", @upperdate, @lowerdate],
                           :offset => @offset,
                           :limit => @limit,
                           :order => @sort.to_s+" "+@find_order.to_s)

      @totalCount = Order.count(:all,
                                :conditions => ["created_at between ? and ?", @upperdate, @lowerdate])

    end

    if params[:query] && params[:search_by]
      case params[:search_by]
      when "customer"
        query = "SELECT orders.* FROM users, orders WHERE (LOWER(users.firstname) LIKE '%#{params[:query].downcase}%' OR LOWER(users.lastname) LIKE '%#{params[:query].downcase}%') AND orders.user_id = users.id"
        @orders = Order.find_by_sql(query)
        @totalCount = Order.count_by_sql(query)
      when "id"
        @orders = Order.find(params[:query]) || nil
        @totalCount = 1 if !@orders.nil?
      else
      end
    end

    if @totalCount == 1
      @orders_xml = '<?xml version="1.0" encoding="UTF-8"?>'
      @orders_xml << "<response>"
      @orders_xml << @orders.to_xml(:skip_instruct => true, :methods => [:current_status, :date, :total]) do |xml|
        xml.totalCount(@totalCount)
      end
      @orders_xml << "</response>"
    else
      @orders_xml = @orders.to_xml(:methods => [:current_status, :date, :total]) do |xml|
        xml.totalCount(@totalCount)
      end
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @orders_xml }
    end
    #    respond_to do |format|
#      case params[:search_by]
#      when "customer"
#        format.xml  { render :xml => @orders_xml }
#      when "id"
#        format.xml
#      else
#        format.html # index.html.erb
#      end
        #      format.xml  { render :xml => @orders.to_xml(:methods => [:current_status, :date, :total]) }
#    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  # { render :xml => @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        flash[:notice] = 'Order was successfully created.'
        format.html { redirect_to(@order) }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        format.html { redirect_to(@order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end

  ##
  ## CUSTOM RESOURCES
  ##
  def front_comment
    @order = session[:order]
    @order.front_comment = params[:c]
    respond_to do |format|
      format.xml { render :xml => @order }
    end
#    session[:order] = @order
  end


  # PUT /orders/:id/status/:status
  def status
    @order = Order.find(params[:id])
    case params[:status]
    when "PENDING"
      @order.update_attribute_with_validation_skipping("status", Order::PENDING)
    when "COMPLETE"
      @order.update_attribute_with_validation_skipping("status", Order::COMPLETE)
    when "SHIPPED"
      @order.update_attribute_with_validation_skipping("status", Order::SHIPPED)
    when "CANCELLED"
      @order.update_attribute_with_validation_skipping("status", Order::CANCELLED)
    else
    end
    respond_to do |format|
      format.xml { render :xml => @order.to_xml(:only => :id) }
#      format.xml { render :xml => "<status>#{@order}</status>" }
#      format.xml { render :xml => @order }
    end
  end

  # PUT /orders/:id/tracking_code
  def tracking_code
    @order = Order.find(params[:id])
    @user = User.find(@order.user_id)
    @order.update_attribute_with_validation_skipping("tracking_code", params[:value])
    Postoffice.deliver_shipped(@order, @user.email)
    respond_to do |format|
      format.xml { render :xml => @order.to_xml(:only => :id) }
    end
  end

  # POST /orders/:id/comments
  def comments
    @order = Order.find(params[:id])
    @user = User.find(@order.user_id)
    @order.update_attribute_with_validation_skipping("comments", params[:value])
    Postoffice.deliver_cancelled(@order, @user.email)
    respond_to do |format|
      format.xml { render :xml => @order.to_xml(:only => :id) }
    end
  end

  def invoice
    @order = Order.find(params[:id])
  end

  def total_shipped(options={})
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    total=0
    Order.find(:all, :conditions=>conditions).each { |order| total += order.total}
    total
  end

  def total_products(options={})
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    total=0
    Order.find(:all, :conditions=>conditions).each { |order| total += order.totalize_products}
    total.round(2)
  end

  def total_shipping(options={})
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    Order.sum('shipping_approx', :conditions=>conditions).round(2)
  end

  def total_warranties(options={})
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    total=0
    Order.find(:all, :conditions=>conditions).each { |order| total += order.totalize_warranties}
    total.round(2)
  end

  def total_taxes(options={})
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    Order.sum('taxes', :conditions=>conditions).round(2)
  end

  def number_cancelled(options={})
    conditions = "status='#{Order::CANCELLED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    Order.count(:conditions=>conditions)
  end

  def number_pending(options={})
    conditions = "status='#{Order::PENDING}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    Order.count(:conditions=>conditions)
  end

  def number_shipped(options={})
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    Order.count(:conditions=>conditions)
  end

  ## options: lowdate, update, condition
  def total_by_condition(options={})
    total = 0
    conditions = "status='#{Order::SHIPPED}'"
    if options[:update]
      conditions += " and (created_at between '#{options[:lowdate]}' and '#{options[:update]}')"
    end
    Order.find(:all, :conditions=>conditions).each do |o|
      o.order_items.each do |i|
        total += i.product_price if i.product && i.product.condition == options[:condition]
      end
    end
    total
  end

  def all_totals
    totals = {
      :total_shipped => total_shipped(params),
      :total_products => total_products(params),
      :total_warranties => total_warranties(params),
      :total_taxes => total_taxes(params),
      :total_shipping => total_shipping(params),
      :number_shipped => number_shipped(params),
      :number_cancelled => number_cancelled(params),
      :number_pending => number_pending(params),
      :total_refurbished => total_by_condition(params.update(:condition => "Refurbished")),
      :total_new => total_by_condition(params.update(:condition => "New")),
      :total_generic => total_by_condition(params.update(:condition => "Generic"))
    }
    respond_to do |format|
      format.xml { render :xml => {:response => totals}.to_xml }
    end
  end

  private
  def pagination
    @offset = 0
    @limit = 25
    if params[:offset] && params[:limit]
      @offset = params[:offset]
      @limit = params[:limit]
    end
  end

  def sort
    @sort = "id"
    @find_order = "DESC"
    if params[:sort] && params[:order]
      @sort = params[:sort]
      @order = params[:order]
    end
  end

  def date
    date = params[:date] || "12"
    case date
    when "today"
      @upperdate = Time.today
      @lowerdate = ""
    when "yesterday"
      @upperdate = date_format(Time.today)
      @lowerdate = date_format()
    when "this_week"
      @upperdate = date_format(Time.now.at_beginning_of_week)
      @lowerdate = date_format(Time.now.tomorrow)
    when "last_week"
      @upperdate = Time.today
      @lowerdate = ""
    when "this_month"
      @upperdate = Time.today
      @lowerdate = ""
    when "last_month"
      @upperdate = Time.today
      @lowerdate = ""
    else
      if date =~ /(\d{2})/
        @upperdate = "2008"+$&+"01"
        @lowerdate = "2008"+$&+"31"
      elsif date =~ /$(\d{8}).(\d{8})^/
        @upperdate = $1
        @lowerdate = $2
      end
    end

    if params[:lowdate] && params[:update]
      @upperdate = params[:lowdate]
      @lowerdate = params[:update]
    end
  end

  def date_format(parse_date)
    fdate = parse_date.to_date.to_s
    fdate.gsub(/\-/, "")
  end
end
