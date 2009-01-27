class AdminKitsController < ApplicationController
  layout "admin"

  before_filter :admin_only

  def index
  end

  def create
    @product = Product.find(params[:id])
    @kit = Kit.new({:kit_type => params[:type]})
    @product << @kit    
  end

  def add_product
  end

  def remove_product
  end
end
