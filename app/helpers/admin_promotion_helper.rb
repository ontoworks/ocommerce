module AdminPromotionHelper
  def qty_html(price_counter)
     html =  "<tr><td align=\"right\">"
     html += text_field(:promotion, "quantity_"+price_counter.to_s, :size => 3)
     html += " items</td><td>$ "
     html += text_field(:promotion, "price_"+price_counter.to_s, :size => 5)
     html += "</td></tr>"
     html
  end
end
