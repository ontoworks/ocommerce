/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

MainPanel = function(){
    this.selected_view = 'users';

    // USERS
    this.grid = new FeedGrid(this, {
    });

//    this.grid.hide();

    // SHIPPING
    this.ship = new ShippingGrid(this, {
    });

    this.ship_options = {
        id:'bottom-preview',
        layout:'fit',
        items:this.ship.options_grid,
        height: 250,
        split: true,
        border:false,
        region:'south'
    }

    // WARRANTIES
    this.warranty = new WarrantyGrid(this, {
    });

/*    this.warranty_products = {
        id:'warrant-products',
        layout:'fit',
        items:this.warranty.preview,
        height: 150,
        split: true,
        border:false,
        region:'south'
    }*/

    this.brands = new BrandGrid(this, {
    });

    this.view_collection = [{
            id:'users',
            bodyBorder: false,
            layout:'border',
            title:'Loading...',
            hideMode:'offsets',
            items: this.grid
        },{
            id:'shipping_modules',
            title: 'Loading',
            layout:'border',
            hideMode:'offsets',
            items: [this.ship, this.ship_options]
        },{
            id:'warranty',
            bodyBorder: false,
            layout:'border',
            title:'Loading...',
            hideMode:'offsets',
//            items: [this.warranty, this.warranty_products]
            items: this.warranty
        },{
            id:'brands',
            bodyBorder: false,
            layout:'border',
            title:'Loading...',
            hideMode:'offsets',
            items: this.brands
        }
    ];

    MainPanel.superclass.constructor.call(this, {
        id:'main-tabs',
        activeItem:2,
        layout: 'card',
        region:'center',
        border: false,
        margins:'0 5 5 0',
        defaults: {
            border:false,
            bodyBorder:false
        },
        items: this.view_collection
    });
};

Ext.extend(MainPanel, Ext.Panel, { 
   loadFeed : function(feed) {
       Ext.getCmp(feed.view).setTitle(feed.text);
       var layout = this.getLayout();

       switch(feed.view) {
       case "users":
           layout.setActiveItem(0);
           this.grid.loadFeed(feed.url);
           break;
       case "shipping_modules":
           layout.setActiveItem(1);
           this.ship.loadFeed(feed.url);
           break;
       case "warranty":
           layout.setActiveItem(2);
           this.warranty.loadFeed(feed.url);
           break;
       case "brands":
           layout.setActiveItem(3);
           this.brands.loadFeed(feed.url);
           break;
       default:
           layout.setActiveItem(0);
           this.grid.loadFeed(feed.url);
           break;
       } 
   }
});