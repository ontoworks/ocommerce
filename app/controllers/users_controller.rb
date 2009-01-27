class UsersController < ApplicationController
  layout "cart"

  before_filter(:pagination)
  before_filter(:sort)

  def index
    if !params[:query].nil?
      @users = User.find_by_like(params[:query], params[:search_by],
        "firstname", "ASC", @limit)

      @users = @users.to_xml do |xml|
        xml.totalCount(User.count_by_like(params[:query], params[:search_by]))
      end
    else
      @users = User.find(:all, :offset => @offset, :limit => @limit,
                         :order => @sort.to_s+" "+@order.to_s)

      @users = @users.to_xml do |xml|
        xml.totalCount(User.count)
      end
    end

    respond_to do |format|
      format.xml  { render :xml => @users }
    end
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    # santiago
    @user.usergroup = "customer"
    #
    @user.save if @user.valid?
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end


  def orders
    @orders = current_user.orders
  end

  def show_order
    @order = current_user.orders.find(params[:order_id])
  end

  # if user exists with :email deliver :password_forgotten
  # email message may be implemented as wanted
  def password_forgotten
    if params[:email]
      @user = User.find_by_email(params[:email])
      if !@user.nil?
        Postoffice.deliver_password_forgotten(@user)
#        redirect_to :controller => "sessions", :action => "new"
      else
        #show error to user: user not found with :email
        @error = "No account was found matching the entered address. Please try again"
      end
    end
  end

  # if user exists with :id and matches :password_key
  # then show new password form
  def password_new
    @user = User.find(params[:id])
    @i = params[:i] || params[:user][:i]
    @valid = false
    @password_changed = false
    if !@user.nil?
      if @user.password_key == @i
        @valid = true
        if params[:user]
          @user.update_attribute_with_validation_skipping("crypted_password", params[:user][:crypted_password])
          if @user.password_key != params[:i]
            @password_changed = true
            #            redirect_to :controller => "sessions", :action => "new"
#            redirect_to :action => "login"
          end
        else
          @aqui = true
        end
      else
        @aqui2= true
      end
    end
  end

  def password_change
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
    @sort = params[:search_by]
    @order = "ASC"
    if params[:sort] && params[:order]
      @sort = params[:sort]
      @order = params[:order]
    end
  end
end
