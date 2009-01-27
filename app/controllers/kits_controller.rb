class KitsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def add_kit_to_cart
    @kit = Kit.find(params[:id])
    @cart = find_cart
    @cart.add_kit(@kit)
  end


  def products
    @kit = Kit.find(params[:id])
    @products = @kit.products
    respond_to do |format|
      format.xml { render :xml => @products }
    end
  end

  def show_products
    @kit = Kit.find(params[:id])
    @products = @kit.products
  end

  # PUT /kits/:id/products/:product_id
  def add_product
    @kit = Kit.find(params[:id])
    @kit.products << Product.find(params[:product_id])
  end

  # DELETE /kits/:id/products/:product_id
  def del_product
    @kit = Kit.find(params[:id])
    @kit.products.delete(Product.find(params[:product_id]))
  end

  # GET /kits/:id/image
  def show_image
    ## esto se hace para limpiar el panel que contiene la imagen. esto es un workaround
    ## puesto q la solucion debe estar en la interfaz
    if params[:id].to_i > 0
      @kit = Kit.find(params[:id])
      @image = @kit.image || false
    else
      @image = false
    end
  end

  # POST /kits/:id/image
  def upload_image
    @kit = Kit.find(params[:id])
    @kit.save_image(params)
    respond_to do |format|
      format.xml { render :xml => @kit }
    end
  end

  ## ATTRIBUTES RESOURCES
  # PUT /kits/:id/price(value)
  def update_price
    @kit = Kit.find(params[:id])
    @kit.update_attribute("price", params[:value])
    respond_to do |format|
      format.xml { render :xml => @kit }
    end
  end
end
