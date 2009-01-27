/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

Ext.onReady(function(){
    Ext.QuickTips.init();

    var Product = Ext.data.Record.create([
           {name: 'image', type: 'string'},
           {name: 'name', type: 'string'},
           {name: 'model', type: 'string'},
           {name: 'condition'}
//           {name: 'price'},
//           {name: 'manufacturer-id', type: 'int'}
      ]);

    var catalogPanel = new Ext.Panel({
        border: true,
        bodyBorder: true,
        height: 600,
        width: 620,
        autoLoad: "catalog"
    });

    var cartPanel = new Ext.Panel({
        title: "Shopping Cart",
        border: true,
        bodyBorder: true,
//        height: 300,
        width: 200,
        autoLoad: "cart/home"
    });

    var homePanel = new Ext.Panel({
        border: false,
        bodyBorder: false,
        applyTo: "catalog",
        height: 800,
        width: 1000,
        layout: 'table',
        layoutConfig: {
          columns: 2
        },
        defaults: {
          bodyStyle: 'padding:6px'
        },
        items: [cartPanel, catalogPanel]
    });

    homePanel.render();


});