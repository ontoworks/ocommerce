/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

FeedGrid = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    this.OrderItem = Ext.data.Record.create([
        {name: 'product-id', type: 'int'},
        {name: 'product-name', type: 'string'},
        {name: 'product-model', type: 'string'},
        {name: 'product-price', type: 'float'},
        {name: 'final-price', type: 'float'},
        {name: 'quantity', type: 'int'}
    ]);

    this.store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'order-item',
              id: 'id'
           }, this.OrderItem),
        sortInfo:{field:'final-price', direction:'DESC'}
    });

    this.columns = [{
        id: 'name',
        header: "Product Name",
        dataIndex: 'product-name',
        sortable:true,
        width: 300
    },{
        header: "Model",
        dataIndex: 'product-model',
        sortable:true,
        width: 70
    },{
        header: "Unit Price",
        dataIndex: 'product-price',
        sortable:true,
        width: 64
    },{
        header: "Qty",
        dataIndex: 'quantity',
        sortable:true,
        width: 30
    },{
        header: "Total",
        dataIndex: 'final-price',
        sortable:true,
        width: 64
    }];

    FeedGrid.superclass.constructor.call(this, {
        region: 'center',
        id: 'topic-grid',
        loadMask: {msg:'Loading Feed...'},

        sm: new Ext.grid.RowSelectionModel({
            singleSelect:true
        }),

        viewConfig: {
//            forceFit:true
        }

    });

};

Ext.extend(FeedGrid, Ext.grid.GridPanel, {
    loadProducts: function (order_id) {
        this.store.proxy = new Ext.data.HttpProxy({
            url: '/orders/'+order_id+'/order_items.xml'
        });
        this.store.load();
    }
});