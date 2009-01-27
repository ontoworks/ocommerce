/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

CouponPanel = function(){
	var coupon_id = 0;
    var Coupon = Ext.data.Record.create([
        {name: 'coupon[name]', mapping: 'name'},
        {name: 'coupon[code]', mapping: 'code'},
        {name: 'coupon[date_up]', mapping: 'date-up'},
        {name: 'coupon[date_down]', mapping: 'date-down'},
        {name: 'coupon[use_times]', mapping: 'use-times'},
		{name: 'coupon[times_used]', mapping: 'times-used'},
		{name: 'coupon[min_price]', mapping: 'min-price'},
		{name: 'coupon[max_price]', mapping: 'max-price'},
		{name: 'coupon[value]', mapping: 'value'},
		{name: 'coupon[discount_by]', mapping: 'discount-by'}
    ]);

    var NewCoupon = Ext.data.Record.create([
        {name: 'name'},
        {name: 'code'},
        {name: 'date_up'},
        {name: 'date_down'},
        {name: 'use_times'},
		{name: 'times_used'},
		{name: 'max_price'},
		{name: 'min_price'},
		{name: 'discount_by'},
		{name: 'value'}
    ]);

	var couponStore = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/coupons.xml',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'coupon',
              id: 'coupon[code]'
           }, Coupon),
		sortInfo:{field:'coupon[date_up]', direction:'DESC'}
	});
	couponStore.load();


    // the DefaultColumnModel expects this blob to define columns. It can be extended to provide
    // custom or reusable ColumnModels
    var colModel = new Ext.grid.ColumnModel([
        {header: "Coupon Title", width: 150, dataIndex: 'coupon[name]'},
        {header: "Start", width: 80, sortable: true, dataIndex: 'coupon[date_up]'},
        {header: "End", width: 80, sortable: true, dataIndex: 'coupon[date_down]'},
        {header: "Times used", width: 80, sortable: true, dataIndex: 'coupon[times_used]'},
        {header: "Code", width: 80, sortable: true, dataIndex: 'coupon[code]'}
    ]);
	
	var discount_by_combo = new Ext.form.ComboBox({
		fieldLabel: "Discount By",
		name: "coupon[discount_by]",
		store: new Ext.data.SimpleStore({
					fields: ['num', 'txt'],
					data : [
						['price', 'Price'],
						['percent', 'Percent']
					]
		}),
		displayField:'txt',
		typeAhead: true,
		mode: 'local',
		triggerAction: 'all',
		selectOnFocus:true
	});

	var details = new Ext.FormPanel({
		id: 'coupon-form',
//		layout: 'fit',
		region: 'south',
		items: {
		xtype: 'fieldset',
		labelWidth: 120,
		title:'Coupon details',
		defaults: {width: 120},	// Default config options for child items
		defaultType: 'textfield',
		autoHeight: true,
//		bodyStyle: Ext.isIE ? 'padding:0 0 5px 15px;' : 'padding:0px 0px;',
		border: false,
		reader: new Ext.data.JsonReader({
					root: 'coupon',
					id: 'id'
				}, NewCoupon),
		url: "/coupons/#{coupon_id}.xml",
		style: {
                "margin-left": "10px", // when you add custom margin in IE 6...
                "margin-right": Ext.isIE6 ? (Ext.isStrict ? "-10px" : "-13px") : "0"  // you have to adjust for it somewhere else
            },
            items: [{
                fieldLabel: 'Name',
                name: 'coupon[name]',
				width: 200
            },{
                fieldLabel: 'Code',
                name: 'coupon[code]',
				readOnly: true,
				width: 200
            },{
                fieldLabel: 'Times usable',
                name: 'coupon[use_times]'
            },{
                fieldLabel: 'Min order price',
                name: 'coupon[min_price]'
            },{
                fieldLabel: 'Max order price',
                name: 'coupon[max_price]'
            },discount_by_combo,{
                fieldLabel: 'Discount value',
                name: 'coupon[value]'
            },{
                xtype: 'datefield',
                fieldLabel: 'Start',
				format: 'Ymd',
                name: 'coupon[date_up]'
            },{
                xtype: 'datefield',
                fieldLabel: 'End',
				format: 'Ymd',
                name: 'coupon[date_down]'
            }]},
		buttons: [{
			id: 'new_btn',
			text: 'New Coupon',
			handler: function() {},
			scope: this },
			{
			text: 'Save',
			handler: function() {
				details.getForm().submit({url: '/coupons.json', waitMsg: 'Updating Info ...', method: "POST"});
			},
			scope: this
         }]
	});

	// On ActionComplete set :code to form and add new :coupon to grid
	details.on("actioncomplete", function(form, action){
		form.setValues({
			'coupon[code]': action.result.coupon.code
		});
		couponStore.add(new Coupon({
			'coupon[name]':details.getForm().findField('coupon[name]').getValue(),
			'coupon[code]':details.getForm().findField('coupon[code]').getValue(),
			'coupon[date_up]':details.getForm().findField('coupon[date_up]').getValue().format('Y-m-d'),
			'coupon[date_down]':details.getForm().findField('coupon[date_down]').getValue().format('Y-m-d'),
			'coupon[times_used]':0
		}));
	}, this);

//	details.on("beforeaction", function(form, action) {
//	});

	CouponPanel.superclass.constructor.call(this, {
		id: 'coupon-panel',
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
		        bodyStyle:'margin:10px'
		    },
			items: [{
				columnWidth: 0.6,
				layout: 'fit',
				region: 'center',
				items: {
					xtype: 'grid',
//					ds: ds,
					store: couponStore,
					cm: colModel,
					sm: new Ext.grid.RowSelectionModel({
						singleSelect: true,
						listeners: {
							rowselect: function(sm, row, rec){
							      Ext.getCmp("coupon-form").getForm().loadRecord(rec);
							}
						}
					}),
					height: 200,
					title: 'Coupons',
					border: true,
/*					listeners: {
						render: function(g){
							g.getSelectionModel().selectRow(0);
						},
						delay: 10 // Allow rows to be rendered.
					}*/
				}
			},details]
		}
	});
};

Ext.extend(CouponPanel, Ext.Panel, {
});