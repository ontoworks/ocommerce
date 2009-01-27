/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

FeedViewer = {};

Ext.onReady(function(){
    Ext.QuickTips.init();

    var order_id = 0;

    var feeds = new FeedPanel();
    var orderProductList = new MainPanel();
    var orderGrid = new OrderGrid();

    orderGrid.on('celldblclick', function(grid, rowIndex, columnIndex, e) {
        var record = grid.store.getAt(rowIndex);
        order_id = record.id;
        orderProductList.list(order_id);
        feeds.loadOrderInfo(order_id);
        feeds.setActiveTab('order-info');
    }, this);

    orderGrid.store.on("load", function(store, records, options) {
            if (store.baseParams.update) {
                feeds.search_info_store.baseParams=store.baseParams;
                feeds.search_info_store.load();
                feeds.setActiveTab('search-info');
            }
        }, this);

    var cosa = new Ext.Panel({
        layout: 'border',
        region: 'center',
        border: false,
        bodyBorder: false,
        items:[{
                id:'bottom-preview',
                layout:'fit',
                margins: '5 0 0 5',
                items:orderGrid,
                height: 500,
                split: true,
                border:false,
                region:'north'},
             orderProductList
         ]
    });

    var viewport = new Ext.Panel({
        el: "entry-div",
        layout:'border',
        title: "Admin Orders",
        items:[
            cosa,
            feeds
         ],
//       defaults: { border: true, bodyBorder: true },
        width: 1000,
        height: 700
    });

    viewport.render();

});