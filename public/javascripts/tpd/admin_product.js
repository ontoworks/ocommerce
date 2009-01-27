function onProductSelect(x) {
  var prod = document.getElementById(x).value;
  var id_match = prod.match(/\((\d+)\)/);
  var id = id_match[1];

  var html = "<tr><td>Price:</td><td>"

  new Ajax.Request('admin_promotion/selected_product_price/'+id, {
      method: "get",
      onSuccess: function(transport) {
          var price_regex = transport.responseText.match(/price\s\$(.+)\$/);
          var price = price_regex[1];
          html += price+"</td></tr>"
          alert(html);
//          new Element.insert();
      }
  });
}