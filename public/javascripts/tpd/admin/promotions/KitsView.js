/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

//FeedViewer = {};

//Ext.onReady(function(){
//    Ext.QuickTips.init();
KitsView = function(product_id, contentView){
    var product_id = "3317";

    var feeds = new FeedPanel();
    var mainPanel = new MainPanel(feeds);
    var searchProduct = new SearchProduct(this, {
    });

    searchProduct.on('celldblclick', function() {
        alert("Double clicked");
    }, this);

    var Kit = Ext.data.Record.create([
        {name: 'price-id'},
        {name: 'kit-type', type: 'string'},
        {name: 'order', type: 'int'}
    ]);

    var kits_store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/kits',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'kit',
              id: 'id'
           }, Kit),
        sortInfo:{field:'order', direction:'ASC'}
    });

    kits_store.on('load', addFeeds, this);
    kits_store.on('loadexception', loadError, this);
    kits_store.load();

    feeds.on('feedselect', function(feed){
        mainPanel.loadFeed(feed);
    });

//    var viewport = new Ext.Panel({
    KitsView.superclass.constructor.call(this, {
        renderTo: contentView,
//        el: "entry-div",
        layout:'border',
        title: "Admin Kits",
        items:[{
                id:'bottom-preview',
                layout:'fit',
                margins: '5 5 0 5',
                items:searchProduct,
                height: 200,
                split: true,
                border:false,
                region:'north'
},
            feeds,
            mainPanel
         ],
        defaults: { border: true, bodyBorder: true },
        width: 800,
        height: 600 
    });

//    viewport.render();

    function loadError() {
        alert("Oops!");
    }

    function addFeeds(store, records, options) {
        if (store.find("kit-type", "platinum") == 0) {
            feeds.addFeed({
                kit_id: records[0].id,
                text: 'Platinum Kit',
                type: 'platinum'
            }, false, true);
        } else {
            feeds.addFeed({
                kit_id: 0,
                text: 'Platinum Kit',
                type: 'platinum'
            }, false, true);
        }
        if (store.find("kit-type", "golden") == 1) {
            feeds.addFeed({
                kit_id: records[1].id,
                text: 'Golden Kit',
                type: 'golden'
            }, true);
        } else {
            feeds.addFeed({
                kit_id: 0,
                text: 'Golden Kit',
                type: 'golden'
            }, true);
        }
        if (store.find("kit-type", "silver") == 2) {
            feeds.addFeed({
                kit_id: records[2].id,
                text: 'Silver Kit',
                type: 'silver'
            }, true);
        } else {
            feeds.addFeed({
                kit_id: 0,
                text: 'Silver Kit',
                type: 'silver'
            }, true);
        }
    } 
};

//});

Ext.extend(KitsView, Ext.grid.GridPanel, {

});
