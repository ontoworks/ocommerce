require "faster_csv"

class GenerateCsvController < ApplicationController
  def index
  end

  def nextag
    products = Product.find(:all)

    header = ["MPN/UPC","Manufacturer","Product Name","Referring Product URL","Product Condition",
              "Availability","Selling Price","Shipping costs", "Weight", "Category"]

    FasterCSV.open('nextag.txt', "w") do |csv|
      csv << header
      for p in products
        model = p.model || ""
        brand = p.brand.nil? ? "" : p.brand.name
        name = p.name || ""
        url = p.url || ""
        condition = p.condition || ""
        price = p.price.nil? ? 0 : p.price.to_s
        weight = p.weight || 0
        category = p.categories.empty? ? "" : p.categories[0].text
        

        str = [model,brand,name,url,condition,"Y",price,0,weight,category]
        csv << str
      end
    end
  end
end