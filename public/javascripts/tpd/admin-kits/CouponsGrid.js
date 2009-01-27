/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

CouponsGrid = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    var Coupon = Ext.data.Record.create([
        {name: 'name', type: 'string'},
        {name: 'date-up', type: 'date'},
        {name: 'date-down', type: 'date'},
        {name: 'use-times', type: 'int'},
        {name: 'used-times', type: 'int'},
        {name: 'active', type: 'boolean'}
    ]);

    this.store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'coupon',
              id: 'id'
           }, Coupon),
        proxy: new Ext.data.HttpProxy({
                url: '/orders/stats/totals',
                method: 'GET'
            }),
        sortInfo:{field:'active', direction:'DESC'}
    });

    this.columns = [{
        id: 'name',
        header: "Product Name",
        dataIndex: 'name',
        sortable:true
        },{
        id: 'date-up',
        header: "Start Date",
        dataIndex: 'date-up',
        sortable:true
        },{
        id: 'date-down',
        header: "End Date",
        dataIndex: 'date-down',
        sortable:true
        },{
        id: 'use-times',
        header: "Use Times",
        dataIndex: 'use-times',
        sortable:true
        },{
        id: 'used-times',
        header: "Used Times",
        dataIndex: 'used-times',
        sortable:true
        }];

    FeedGrid.superclass.constructor.call(this, {
        id: 'coupon-grid',
        loadMask: {msg:'Loading Coupons...'},

        sm: new Ext.grid.RowSelectionModel({
            singleSelect:true
        })
    });
};

Ext.extend(CouponsGrid, Ext.grid.GridPanel, {
});