class ShippingController < ApplicationController
  before_filter(:pagination)
  before_filter(:sort)

  skip_before_filter :verify_authenticity_token

  def index
    @shippings = ShippingModule.find(:all)

    respond_to do |format|
      format.xml  { render :xml => @shippings }
    end
  end

  def options
    @shipping = ShippingModule.find(params[:id])
    @options = @shipping.shipping_options

    respond_to do |format|
      format.xml  { render :xml => @options }
    end
  end

  private
  def pagination
    @offset = 0
    @limit = 20
    if params[:offset] && params[:limit]
      @offset = params[:offset]
      @limit = params[:limit]
    end
  end

  def sort
    @sort = "firstname"
    @order = "DESC"
    if params[:sort] && params[:order]
      @sort = params[:sort]
      @order = params[:order]
    end
  end
end
