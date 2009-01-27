/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

CouponPanel = function(){
    var Coupon = Ext.data.Record.create([
        {name: 'name'},
        {name: 'code'},
        {name: 'date-up'},
        {name: 'date-down'},
        {name: 'use-times'},
		{name: 'times-used'},
		{name: 'order-total-up'},
		{name: 'order-total-down'},
		{name: 'discount'}
    ]);

	var couponStore = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/coupons',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'coupon',
              id: 'id'
           }, Coupon),
		sortInfo:{field:'order', direction:'ASC'}
	});

    // the DefaultColumnModel expects this blob to define columns. It can be extended to provide
    // custom or reusable ColumnModels
    var colModel = new Ext.grid.ColumnModel([
        {header: "Coupon Title", width: 75, dataIndex: 'name'},
        {header: "Start", width: 75, sortable: true, dataIndex: 'date-up'},
        {header: "End", width: 75, sortable: true, dataIndex: 'date-down'},
        {header: "Times used", width: 85, sortable: true, dataIndex: 'times-used'}
    ]);
	
	var details = new Ext.FormPanel({
//		layout: 'fit',
		region: 'south',
		items: {
		xtype: 'fieldset',
		labelWidth: 90,
		title:'Coupon details',
		defaults: {width: 120},	// Default config options for child items
		defaultType: 'textfield',
		autoHeight: true,
		bodyStyle: Ext.isIE ? 'padding:0 0 5px 15px;' : 'padding:10px 5px;',
		border: false,
		style: {
                "margin-left": "10px", // when you add custom margin in IE 6...
                "margin-right": Ext.isIE6 ? (Ext.isStrict ? "-10px" : "-13px") : "0"  // you have to adjust for it somewhere else
            },
            items: [{
                fieldLabel: 'Name',
                name: 'name'
            },{
                fieldLabel: 'Times usable',
                name: 'use-times'
            },{
                fieldLabel: 'Max order price',
                name: 'order-total-up'
            },{
                fieldLabel: 'Min order price',
                name: 'order-total-down'
            },{
                xtype: 'datefield',
                fieldLabel: 'Start',
                name: 'date-up'
            },{
                xtype: 'datefield',
                fieldLabel: 'End',
                name: 'date-down'
            }]}
	});

	MainPanel.superclass.constructor.call(this, {
		id: 'company-form',
		region: 'center',
		frame: true,
		labelAlign: 'left',
		//        title: 'Company data',
		//        bodyStyle:'padding:5px',
		margins: '5 5 5 0',
		//        width: 750,
		//        layout: 'column',	// Specifies that the items will now be arranged in columns
//		layout: 'fit',
		items: {
			layout: 'table',
			layoutConfig: {
				columns: 1
			},
			defaults: {
		        bodyStyle:'margin:20px'
		    },
			items: [{
				columnWidth: 0.6,
				layout: 'fit',
				region: 'center',
				items: {
					xtype: 'grid',
					ds: ds,
					cm: colModel,
					sm: new Ext.grid.RowSelectionModel({
						singleSelect: true,
						listeners: {
							rowselect: function(sm, row, rec){
							//      Ext.getCmp("company-form").getForm().loadRecord(rec);
							}
						}
					}),
					autoExpandColumn: 'company',
					height: 150,
					title: 'Company Data',
					border: true,
					listeners: {
						render: function(g){
							g.getSelectionModel().selectRow(0);
						},
						delay: 10 // Allow rows to be rendered.
					}
				}
			},details]
		}
	});

/*    MainPanel.superclass.constructor.call(this, {
        id:'main-tabs',
		activeTab:0,
        region:'center',
        margins:'0 5 5 0',
        resizeTabs:true,
        tabWidth:500,
        minTabWidth: 120,
        enableTabScroll: true,
		border: false,
        items: {
			id: 'main_view',
			layout: 'border',
			title: 'Hola Mundo',
			hideMode: 'offsets',
			items:[
				{	id:'bottom-preview',
					layout:'fit',
					margins: '5 5 0 5',
					items:searchProduct,
					height: 200,
					split: true,
					border:false,
					region:'north'
				},{
					id:'main-view',
					layout:'fit',
					title:'Products in this promotion',
					split: true,
					hideMode:'offsets',
					region: 'center',
					border:false,
					items:this.grid
				}
			]
        }
    });*/
};

Ext.extend(CouponPanel, Ext.Panel, {
});