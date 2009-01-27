class CouponsController < ApplicationController
  before_filter :admin_only, :only => [:new, :edit, :create, :update]

  skip_before_filter :verify_authenticity_token

  # GET /coupons
  # GET /coupons.xml
  def index
    @coupons = Coupon.find(:all)

    if @coupons.empty?
      @coupons << Coupon.new({
                               :id => 999,
                               :name => "Test coupon",
                               :code => "TESTCODE123",
                               :date_up => "20080101",
                               :date_down => "20080131",
                               :use_times => 100,
                               :max_price => 0,
                               :min_price => 1000,
                               :created_at => "20080101",
                               :value => "100",
                               :discount_by => "price"
                             })
    end

    respond_to do |format|
      format.xml {render :xml => @coupons.to_xml(:methods => [:times_used])}
    end
  end

  # GET /coupons/1
  # GET /coupons/1.xml
  def show
    @coupons = Coupon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  # GET /coupons/new
  # GET /coupons/new.xml
  def new
    @coupons = Coupon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  # GET /coupons/1/edit
  def edit
    @coupons = Coupon.find(params[:id])
  end

  # POST /coupons
  # POST /coupons.xml
  def create
#    debugger
    @coupon = Coupon.new(params[:coupon])
    @coupon.code = Coupon.generate_new_code
    # @xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    @xml = "<response>\n"

    respond_to do |format|
      if @coupon.save
        @xml << @coupon.to_xml(:only => [:id, :code], :skip_instruct => true) << "</response>"
        flash[:notice] = 'Coupons was successfully created.'
        format.html { redirect_to(@coupon) }
        format.xml  { render :xml => @xml, :status => :created, :location => @coupon }
        format.json { render :json => {:success => true, :coupon => @coupon} }
#        format.json { render :json => @coupon.to_json(:only => [:id, :code]) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coupons/1
  # PUT /coupons/1.xml
  def update
    @coupons = Coupon.find(params[:id])

    respond_to do |format|
      if @coupons.update_attributes(params[:coupons])
        flash[:notice] = 'Coupons was successfully updated.'
        format.html { redirect_to(@coupons) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coupons.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.xml
  def destroy
    @coupons = Coupons.find(params[:id])
    @coupons.destroy

    respond_to do |format|
      format.html { redirect_to(coupons_url) }
      format.xml  { head :ok }
    end
  end
end
