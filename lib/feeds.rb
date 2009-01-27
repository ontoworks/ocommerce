require 'csv'
require 'net/ftp'
require 'net/http'
require 'rubygems'
require 'builder'
require "faster_csv"

#@products = Product.find(:all, :conditions => ["status = ?", "Y"])

def nextag
  file_path = "/tmp/nextagfeed.txt"
  nextag = File.new(file_path, "w+")
  CSV::Writer.generate(nextag, "\t") do |csv|
    csv << ["MPN/UPC","Manufacturer","Product Name","Referring Product URL","Product Condition","Availability",
            "Selling Price","Shipping costs","Weight (if H is not used, this column is needed)","Category",
            "description","imageurl"]
    @products.each do |product|
      category = product.category.nil? ? "" : product.category.text
      if product.subscribed_to?("nextag")
        csv << [product.model, product.name.split[0], product.name,
                "http://www.theprinterdepot.net#{product.url}",
                product.condition.upcase, product.status, product.price("customer"),
                "#{product.free_shipping ? 0 : ""}", product.weight, category, product.description,
                "http://www.theprinterdepot.net/images/products/#{product.image}"]
      end
    end
  end
  nextag.close
#  send_to_ftp("ftp.nextag.com", "printerdepot.u74", "F5d34yt", file_path, "private/printerdepot")
end

def pricegrabber
  file_path = "/tmp/UploadToPriceGrabberJanuary3.txt"
  price_grabber = File.new(file_path, "w+")
  CSV::Writer.generate(price_grabber, "\t") do |csv|
    csv << ["MPN/UPC","Manufacturer","Product Name","Referring Product URL","Product Condition",
            "Availability","Selling Price","Shipping costs","Weight (if H is not used, this column is needed)"]
    @products.each do |product|
      if product.subscribed_to?("pricegrabber")
        csv << [product.model, product.name.split[0], product.name,
                "http://www.theprinterdepot.net#{product.url}",
                product.condition.upcase, product.status, product.price("customer"),
                "#{product.free_shipping ? 0 : ""}", product.weight]
      end
    end
  end
  price_grabber.close
#  send_to_ftp("ftp.pricegrabber.com", "theprinterdepot", "bjkPm30", file_path)
end

def shopzilla
  shopzilla = File.new("/tmp/shopzilla_feed.txt", "w+")
  CSV::Writer.generate(shopzilla, "\t") do |csv|
    csv << ["Category","Manufacturer","Title","Description","Link","Image","SKU","Quantity on Hand","Condition",
              "Shipping Weight","Shipping Cost","Bid","Promo Text","UPC","Price" ]

    @products.each do |product|
      if product.subscribed_to?("shopzilla")
        csv << ["420", product.name.split[0], product.name, product.description,
                "http://www.theprinterdepot.net#{product.url}",
                "http://www.theprinterdepot.net/images/products/#{product.image}",
                product.model, "1", product.condition.upcase, product.weight, "#{product.free_shipping ? 0 : ""}", "", "", "",
                product.price("customer")]
      end
    end
  end
  shopzilla.close
end

#Product.(:all, :select => "category, status", :include => ["category"], :conditions => ["status = ?", "Y"]).each do |p|
def google
  feed = ""
  xml = Builder::XmlMarkup.new(:target => feed, :indent => 1)
#  Product.find(:all, :conditions => ["status = ?", "Y"]).each do |p|
  xml.instruct!
  xml.feed "xmlns" => "http://www.w3.org/2005/Atom", "xmlns:g" => "http://base.google.com/ns/1.0",
  "xmlns:batch" => "http://schemas.google.com/gdata/batch" do
    Product.find_all_by_status("Y").each do |p|
#    p=Product.find(3040)
      if !p.category.nil?
        case p.category.id
        when 1,10,12,14,16,217
          xml.entry do
            xml.batch :id do xml.text! p.id.to_s end
            xml.batch :operation, "type" => "insert"
            xml.title(p.name)
            xml.id(p.id.to_s)
            xml.link :rel => "alternate", :type => "text/html", :href => "http://www.theprinterdepot.net/#{p.url}"
            xml.summary(p.description)
            xml.author "The Printer Depot"

            xml.g :item_type do xml.text! "products" end
            xml.g :brand do xml.text! p.brand.name end
            xml.g :price_units do xml.text! "USD" end
            xml.g :model_number do xml.text! p.model end
            xml.g :condition do xml.text! p.condition end
            xml.g :image_link do xml.text! "http://www.theprinterdepot.net/images/products/#{p.model}_thumb.jpg" end
            xml.g :price do xml.text! p.price("customer").to_s end
            xml.g :department do xml.text! p.category.text end
            xml.g :product_type do xml.text! p.category.text end
          end
        end
      else
      end
    end
  end

  send_to_google(feed)
  #  puts data

end

def send_to_google(data)
  server = Net::HTTP.new("www.google.com")
  path = path = "/base/feeds/items/batch"
  headers = {
    "Content-Type" => "application/atom+xml",
    # sgaviria@gmail.com
    # "Authorization" => "AuthSub token=\"CInwwZG2GBDbvvuX-P____8B\"",
    # "X-Google-Key" => "key=ABQIAAAA7VerLsOcLuBYXR7vZI2NjhTRERdeAiwZ9EeJWta3L_JZVS0bOBRIFbhTrQjhHE52fqjZvfabYYyn6A"

    # sales@theprinterdepot.net
    "Authorization" => "AuthSub token=\"CJbVhaThAxC81dfy-v____8B\"",
    "X-Google-Key" => "key=ABQIAAAAi0vtKAzDuwHUBJ-ror7gUhRh5Y_MmiEF34VMnjbu2K8uNdNxdRQekmYtZSTZEQ-kB8TBo_IwG1GGjg"

  }

  resp = server.post(path, data, headers)
  resp.body
end

def send_to_ftp(server, user, password, file, dir=nil)
  ftp = Net::FTP.new(server)
  ftp.login(user, password)
  ftp.chdir(dir) unless dir.nil?
  ftp.puttextfile(file)
  ftp.close
end

def read_feed
  model, brand, condition, price, quantity, name = ""
  FasterCSV.foreach("/home/tpd/rails/lib/feed_me.csv") do |row|
    model, brand, condition, price, quantity, name = *row
    p = Product.find_by_model(model)
    if p.nil?
      p = Product.create(:status => "Y",
        :description => name,
        :model =>  model,
        :brand_id => Brand.find_by_name(brand).id,
        :condition => condition,
        :price => price,
        :name => name,
        :image => "no_image",
	:category_id => 13)
      puts "Nuevo:#{p.model}"
    else
      p.update_attributes({:image => "no_image"})
      p.save
      puts "Actualiza:#{p.name}"
    end
  end
end

def update_feed
  model, brand, condition, price, quantity, name = ""
  FasterCSV.foreach("/home/tpd/rails/lib/feed_me.csv") do |row|
    model, brand, condition, price, quantity, name = *row
    p = Product.find_by_model(model)
    if p.price == 0
      p.price=price
      update_attributes({:category_id => 13})
    end
  end	
end

# Handling price based on the requirements
def handling_price(weight)
  if between?(weight, 20, 50)
    10
  elsif between?(weight, 50, 100)
    20
  elsif between?(weight, 101, 10000)
    40
  end
end

def between?(weight, a, b)
  weight >= a && weight <= b
end

