class AdminProductsController < ApplicationController
  layout "admin"

  before_filter :admin_only

  def index
    @brands = Brand.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def related_products
    @product = Product.find(params[:id])
  end

  def kits
    @product = Product.find(params[:id])
  end
end
