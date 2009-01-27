# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout "cart"

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      reset_user_cart
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      redirect_back_or_default("/sessions/new")
    end
  end

  # do something nice instead of deleting existing cart for user
  def reset_user_cart
      if !current_user.cart.nil?
        current_user.cart.cart_items.destroy_all
        Cart.delete(current_user.cart)
      end
      current_user.cart = session[:cart]
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
