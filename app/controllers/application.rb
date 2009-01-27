# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
#  include ExceptionNotifiable

#  include SslRequirement

  before_filter(:ui_stuff)
  before_filter(:uri)

  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '449304e62e567c06fe0a3427c2572e1f'

  def usergroup
    current_user.nil? ? "customer" : current_user.usergroup
  end

  def find_cart
    # any session always contains a cart
    # esto hay q arreglarlo pq da problemas cuando no hay
    if session[:cart].nil?
      cart = Cart.create
      session[:cart] = cart
    end
    session[:cart]
  end

  private

  def admin_only
    store_location
    if !(current_user && admin?)
      flash[:notice] = "Please login first"
      redirect_to :controller => :admin, :action => :login
    end
#    redirect_to :action => :index
  end

  def uri
    @uri = request.request_uri
  end

  def categories_list
    Category.find(:all)
  end

  def ui_stuff
    @cart = find_cart
    @categories = categories_list
    @supplies = Category.find(:all, :conditions => ["parent_id = ?", 210 ])
    @brands = Brand.find(:all)
  end
end
