class AdminOrdersController < ApplicationController
  before_filter(:pagination)
  before_filter(:sort)
  before_filter :admin_only

  layout "admin"

  def index
    @orders = Order.find(:all, :offset => @offset, :limit => @limit, 
                         :order => @sort.to_s+" "+@order.to_s)
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
    @sort = "created_at"
    @order = "DESC"
    if params[:sort] && params[:order]
      @sort = params[:sort]
      @order = params[:order]
    end
  end
end
