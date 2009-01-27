Ext.onReady(function(){
    Ext.QuickTips.init();

    var product_id = '3317';
    var ProductDesc = Ext.data.Record.create([
        {name: 'product_id'},
        {name: 'specs'},
        {name: 'features'},
        {name: 'includes'},
        {name: 'warranty'},
        {name: 'overview'},
        {name: 'features_desc'}
    ]);

    var PriceList = Ext.data.Record.create([
           {name: 'customer', type: 'float'},
           {name: 'business', type: 'float'},
           {name: 'wholesale', type: 'float'},
    ]);

    this.specs_form = new Ext.FormPanel({
        labelWidth: 75, // label settings here cascade unless overridden
//        frame:true,
        title: 'Specs',
        bodyStyle:'background:white; padding:5px 5px 0',
        width: 260,
        height: 300,
        layout: 'fit',
        border: false,
        reader: new Ext.data.XmlReader({
            record: 'price'
        }, PriceList),
        url: 'products'+'/'+product_id+'/prices',
        method: 'GET',

        items: [{
            border: false,
            xtype:'fieldset',
            title: 'Price Contexts',
            autoHeight:true,
            defaults: {width: 100},
            width:220,
            defaultType: 'textfield',
            allowDomMove: true,
            style:'background:white',

            items :[
            {
                fieldLabel: 'Customer',
                name: 'customer'
            },{
                fieldLabel: 'Business',
                name: 'business'
            },{
                fieldLabel: 'Wholesale',
                name: 'wholesale'
            },{
                name: 'id',
                inputType: 'hidden',
                value: product_id
            }]
       }],
       buttons: [{
            text: 'Save',
            handler: function() {
                this.specs_form.getForm().submit({url: '/products/save_prices_list', waitMsg: 'Updating Prices ...', method: "POST"});
            },
            scope: this
       }]
    });

    this.specs_form.getForm().load();


    // SAME PANEL TO RENDER TO EXTERNAL DIV
    this.specs_form2 = new Ext.FormPanel({
        renderTo: 'form-alone',
        labelWidth: 75, // label settings here cascade unless overridden
        frame:true,
        title: 'Specs',
        bodyStyle:'background:white; padding:5px 5px 0',
        width: 260,
        height: 300,
        layout: 'fit',
        border: false,
        reader: new Ext.data.XmlReader({
            record: 'price'
        }, PriceList),
        url: 'products'+'/'+product_id+'/prices',
        method: 'GET',

        items: [{
            border: false,
            xtype:'fieldset',
            title: 'Price Contexts',
            autoHeight:true,
            defaults: {width: 100},
            width:220,
            defaultType: 'textfield',
            allowDomMove: true,
            style:'background:white',

            items :[
            {
                fieldLabel: 'Customer',
                name: 'customer'
            },{
                fieldLabel: 'Business',
                name: 'business'
            },{
                fieldLabel: 'Wholesale',
                name: 'wholesale'
            },{
                name: 'id',
                inputType: 'hidden',
                value: product_id
            }]
       }],
       buttons: [{
            text: 'Save',
            handler: function() {
                this.specs_form.getForm().submit({url: '/products/save_prices_list', waitMsg: 'Updating Prices ...', method: "POST"});
            },
            scope: this
       }]
    });

    this.specs_form2.getForm().load();

    var tabs = new Ext.TabPanel({
        title: 'Product Specs',
        renderTo: 'tabs',
        width:600,
        height: 500,
        activeTab: 0,
        frame:true,
        defaults:{autoHeight: true},
        items:[ this.specs_form
        ]
    });
});
