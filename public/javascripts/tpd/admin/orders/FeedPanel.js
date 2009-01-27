/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

FeedPanel = function() {
    var tpl = new Ext.XTemplate(
        '<tpl for=".">',
            '<p>',
            '<b>Billing To</b><br/>',
            '{billing_name}<br/>',
            '{billing_street_address}<br/>',
            '{billing_city}, {billing_state}<br/>',
            '{billing_country}<br/>',
            '</p>',
            '<br/>',
            '<p>',
            '<b>Shipping To</b><br/>',
            '{delivery_name}<br/>',
            '{delivery_street_address}<br/>',
            '{delivery_city}, {delivery_state}<br/>',
            '{delivery_country}<br/>',
            '</p>',
            '<br/>',
            '<p>',
            '<b>Shipping Details</b><br/>',
            'Carrier: {carrier}<br/>',
            'Method: {shipping_method}<br/>',
            'Rate: ${shipping_approx}<br/>',
            '</p>',
            '<br/>',
            '<p>',
            '<b>Payment Details</b><br/>',
            'Method: {payment_method}<br/>',
            '<b>TOTAL PAYED: ${total}</b><br/>',
            '</p>',
            '<div class="thumb-wrap" id="hola">',
            '<div class="thumb"><img src="hola" title="hola"></div>',
            '<span class="x-editable"></span></div>',
            '<tpl if="this.isCreditCard(payment_method)">',
            '<p>',
            '<b>- Credit Card Details</b><br/>',
            'Card: {cc_type}<br/>',
            'Owner: {cc_owner}<br/>',
            'Number: {cc_number}<br/>',
            'CVV: {cvvnumber}<br/>',
            'Expiration Date: {cc_expires}<br/>',
            '</tpl>',
            '</p>',
            '<br/>',
            '<tpl if="this.trackingCode(tracking_code)">',
            '<p>',
            '<b>Tracking code</b><br/>',
            '{tracking_code}<br/>',
            '</p>',
            '</tpl>',
            '<br/>',
            '<tpl if="this.hasFrontComment(front_comment)">',
            '<p>',
            '<b>Comments and suggestions</b><br/>',
            '{front_comment}<br/>',
            '</p>',
            '</tpl>',
            '<br/>',
            '<tpl if="this.isCancelled(comments)">',
            '<p>',
            '<b>Cancel reason</b><br/>',
            '{comments}<br/>',
            '</p>',
            '</tpl>',
            '<a href="/orders/{id}/invoice">View Invoice</a>',
        '</tpl>',
        '<div class="x-clear"></div>', {
        hasFrontComment: function(front_comment) {
            return front_comment;
        },
        isCreditCard: function(payment_method) {
            return payment_method == "credit card";
        },
        trackingCode: function(tracking_code) {
            return tracking_code != "";
        },
        isCancelled: function(comments) {
          if (comments) {
              return true;
          } else {
              return false;
          }
        }
    });

   var search_tpl = new Ext.XTemplate(
        '<tpl for=".">',
            '<p><b>Totals for shipped orders</b></p>',
            '<p>  Total shipped: ${total-shipped}</p>',
            '<p>  Total products: ${total-products}</p>',
            '<p>  Total shipping: ${total-shipping}</p>',
            '<p>  Total warranties: ${total-warranties}</p>',
            '<p>  Total taxes: ${total-taxes}</p>',
            '<br/><p><b>Number of orders by status</b></p>',
            '<p>  Number shipped:{number-shipped}</p>',
            '<p>  Number cancelled:{number-cancelled}</p>',
            '<p>  Number pending:{number-pending}</p>',
        '</tpl>'
   );

   var OrderInfo = Ext.data.Record.create([
        {name: 'billing_city', type: 'string'},
        {name: 'billing_company', type: 'string'},
        {name: 'billing_country', type: 'string'},
        {name: 'billing_name', type: 'string'},
        {name: 'billing_postcode', type: 'string'},
        {name: 'billing_state', type: 'string'},
        {name: 'billing_street_address', type: 'string'},
        {name: 'billing_suburb', type: 'string'},
        {name: 'delivery_city', type: 'string'},
        {name: 'delivery_company', type: 'string'},
        {name: 'delivery_country', type: 'string'},
        {name: 'delivery_name', type: 'string'},
        {name: 'delivery_postcode', type: 'string'},
        {name: 'delivery_state', type: 'string'},
        {name: 'delivery_street_address', type: 'string'},
        {name: 'delivery_suburb', type: 'string'},
        {name: 'shipping_approx', type: 'float'},
        {name: 'shipping_method', type: 'string'},
        {name: 'payment_method', type: 'string'},
        {name: 'total', type: 'float'},
        {name: 'carrier', type: 'string'},
        {name: 'cc_type'},
        {name: 'cc_owner'},
        {name: 'cc_number'},
        {name: 'cvvnumber'},
        {name: 'cc_expires'},
        {name: 'tracking_code'},
        {name: 'comments'},
        {name: 'front_comment'},
        {name: 'id', type: 'int'}
    ]);

   var SearchInfo = Ext.data.Record.create([
        {name: 'total-shipped', type: 'float'},
        {name: 'total-products', type: 'float'},
        {name: 'total-warranties', type: 'float'},
        {name: 'total-taxes', type: 'float'},
        {name: 'total-shipping', type: 'float'},
        {name: 'number-shipped', type: 'float'},
        {name: 'number-cancelled', type: 'float'},
        {name: 'number-pending', type: 'float'}
    ]);

    this.store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'order'
           }, OrderInfo),
        sortInfo:{field:'shipping_method', direction:'DESC'}
    });

    this.search_info_store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'response'
           }, SearchInfo),
        proxy: new Ext.data.HttpProxy({
                url: '/orders/stats/totals',
                method: 'GET'
            }),
        sortInfo:{field:'total-shipped', direction:'DESC'}
    });

    var customer_info = new Ext.Panel({
        id:'order-info',
        frame:true,
        autoHeight:true,
        collapsible:true,
        layout:'fit',
        title:'Order Details',

        items: new Ext.DataView({
            store: this.store,
            tpl: tpl,
            scope: this,
            autoHeight:true,
            multiSelect: true,
            overClass:'x-view-over',
            itemSelector:'div.thumb-wrap',
            emptyText: 'No images to display'
        })
    });

    var search_info = new Ext.Panel({
        id:'search-info',
        frame:true,
        autoHeight:true,
        collapsible:true,
        layout:'fit',
        title:'Search Details',

        items: new Ext.DataView({
            store: this.search_info_store,
            tpl: search_tpl,
            scope: this,
            autoHeight:true,
            multiSelect: true,
            overClass:'x-view-over',
            itemSelector:'div.thumb-wrap',
            emptyText: 'No information to display'
        })
    });

    FeedPanel.superclass.constructor.call(this, {
        id:'feed-tree',
        activeTab:0,
        enableTabScroll: true,
        region:'east',
//        title:'Order info',
        split:true,
        width: 250,
        minSize: 180,
        maxSize: 180,
        margins:'5 5 5 0',
        cmargins:'5 5 5 5',
        autoScroll:true,
                items: [customer_info,search_info]
    });


};

Ext.extend(FeedPanel, Ext.TabPanel, {
    isCreditCard: function() {
        return true;
    },

    loadOrderInfo: function (order_id) {
        this.store.proxy = new Ext.data.HttpProxy({
            url: '/orders/'+order_id+'.xml'
        });
        this.store.load();
    }
});