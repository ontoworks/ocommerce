class CatalogController < ApplicationController
  def index
    @products = Product.find(:all, :order => "times_ordered DESC", :limit => 16)
    respond_to do |format|
      format.html
    end
  end
end
