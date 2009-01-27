class SitemapController < ApplicationController
  def index
    @products = Product.find_all_by_status("Y")
    respond_to do |format|
#      format.html
      format.xml
    end
  end
end
