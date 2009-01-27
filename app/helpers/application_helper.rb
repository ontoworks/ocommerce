require 'paypal'

module ApplicationHelper
  include Paypal::Helpers

  def free_shipping?(product)
    ""
    if product.free_shipping
      "<p>Free Shipping</p>"
    end
  end

  def warranty?(item)
    ""
    if (item.has_warranty?)
      html = "<p>#{item.warranty.title}</p><p>$#{item.warranty.price} "
      if !session[:checkout]
        html += link_to_remote "Remove", :url => {:controller => "cart", :action => "remove_warranty", :id => item }, :method => :delete
      end
      html += "</p>"
      html
    end
  end

  def cart_qty_field?
    uris = [
      "/cart/step3",
      "/cart/step4"
    ]
    !uris.include? @uri
  end

  def search_path
    @search_path = ""
    if !session[:search_by][:brand].nil?
      @brand = Brand.find(session[:search_by][:brand])
      @search_path += "Brand: #{@brand.name} / "
    end
    if !session[:search_by][:category].nil?
      @category = Category.find(session[:search_by][:category])
      @search_path += "Category: #{@category.text} / "
    end
    if !session[:search_by][:condition].nil?
      @search_path += "Condition: #{session[:search_by][:condition]} / "
    end
    if !session[:search_by][:price].nil?
      @price_range = session[:search_by][:price].split(/to/)
      @search_path += "Price: $#{@price_range[0]} - $#{@price_range[1]} / "
    end
    @search_path
  end

  def filters_exist?
    session[:search_by][:filters_exist]
  end

  def cart_exists?
    true
    if session[:cart].nil?
      false
    end
  end

  def cart_empty?
    return true if session[:cart].nil?
    session[:cart].empty?
  end

  def show_component_for_uri?(component, uri)
    case component
    when "cart"
      if uri =~ /paypal/
        false
      elsif uri =~ /direct/
        false
      elsif uri =~ /thank_you/
        false
      else
        true
      end
    when "promo"
      if uri =~ /paypal/
        false
      elsif uri =~ /direct/
        false
      elsif uri =~ /thank_you/
        false
      else
        true
      end
    when "context_box_footer"
      if uri =~ /paypal/
        false
      elsif uri =~ /direct/
        false
      elsif uri =~ /thank_you/
        false
      else
        true
      end
    end
  end

  def hide?(id)
    @cart = session[:cart]
    hide = "style=\"display: none;\""
    case id
    when "checkout_btn_div"
      if @cart.nil? || @cart.empty? || session[:checkout]
        hide
      end

    when "product_info_top"
      hide
    when "product_info_hot"
      hide
    when "freight_wait"
      hide
    when "freight_quotes"
      hide
    when "empty_cart"
#      if @cart.nil? || @cart.empty?
      if cart_exists? || !cart_empty?
        hide
      end
    when "cart_head"
      if !cart_exists? || cart_empty?
#      if @cart.nil? || @cart.empty?
        hide
      end
    else
    end
  end

  def hide_div?(id)
    case id
    when "checkout_btn_div"
      @cart = session[:cart]
      if @cart.empty?
        "style=\"display: none;\""
      end
#      ""
    else
    end
  end

  def usergroup
    "customer"
    if !current_user.nil?
      current_user.usergroup
    end
  end

  def tree_select(categories, model, name, selected=0, level=0, init=true)
    html = ""
    # The "Root" option is added
    # so the user can choose a parent_id of 0
    if init
        # Add "Root" to the options
        html << "<select name=\"#{model}[#{name}]\" id=\"#{model}_#{name}\">\n"
        html << "\t<option value=\"0\""
        html << " selected=\"selected\"" if selected.parent_id == 0
        html << ">Root</option>\n"
    end

    if categories.length > 0
      level += 1 # keep position
      categories.collect do |cat|
        html << "\t<option value=\"#{cat.id}\" style=\"padding-left:#{level * 10}px\""
        html << ' selected="selected"' if cat.id == selected.parent_id
        html << ">#{cat.text}</option>\n"
        html << tree_select(cat.children, model, name, selected, level, false)
      end
    end
    html << "</select>\n" if init
    return html
  end
end
