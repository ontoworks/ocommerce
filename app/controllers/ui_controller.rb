class UiController < ApplicationController
  def ui_proxy
    type = params[:type]
    view = params[:view]
    id = params[:id]
    action = "#{type}_#{view}"
    @product = Product.find(id)
    render :action => action
  end

  def product_quickview
  end
end
