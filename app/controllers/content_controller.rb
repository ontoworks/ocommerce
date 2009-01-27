class ContentController < ApplicationController
  before_filter(:ui_stuff)

  layout "home"

  def index
  end

  def contactus
  end

  private
  def ui_stuff
    @cart = find_cart
    @categories = categories_list
    @supplies = Category.find(:all, :conditions => ["parent_id = ?", 210 ])
  end

  def categories_list
    Category.find(:all)
  end
end
