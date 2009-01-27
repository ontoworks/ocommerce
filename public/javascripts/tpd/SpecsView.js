

SpecsView = function(product_id, contentView){
    this.contentView = contentView;

    var ProductDesc = Ext.data.Record.create([
        {name: 'product_id'},
        {name: 'specs'},
        {name: 'features'},
        {name: 'includes'},
        {name: 'warranty'},
        {name: 'overview'},
        {name: 'features_desc'}
    ]);

    SpecsView.superclass.constructor.call(this, {
        title: 'Product Specs',
        renderTo: contentView,
        width:900,
        height: 600,        hideBorders: true,
        labelWidth: 75, // label settings here cascade unless overridden
        frame:true,
        standardSubmit: true,
        bodyStyle:'background:white; padding:5px 5px 0;',
        reader: new Ext.data.XmlReader({ record: 'product_description' }, ProductDesc),
        url: 'products'+'/'+product_id+'/specs',
        method: 'GET',

        layout: 'column',
        layoutConfig: { columns: 3},

        items: [
        {
            border: false,
            xtype:'fieldset',
            rowspan: 2,
            title: 'Specs',
            autoHeight:true,
            defaults: {width: 210},
            defaultType: 'textarea',
            items :
            {
                fieldLabel: 'Specs',
                name: 'XXspecsXX',
                width: 400,
                height: 150,
//                grow: true,
                hideLabel: true
            }
         },
        {
            border: false,
            xtype:'fieldset',
            rowspan: 2,
            title: 'Features',
            autoHeight:true,
            defaults: {width: 210},
            defaultType: 'textarea',
            items :
            {
                fieldLabel: 'Features',
                name: 'features',
                width: 400,
                height: 150,
                hideLabel: true
            }
         },
        {
            border: false,
            xtype:'fieldset',
            rowspan: 2,
            title: 'Includes',
            autoHeight:true,
            defaults: {width: 210},
            items :
            {
                xtype:'textarea',
                fieldLabel: 'Includes',
                name: 'includes',
                width: 400,
                height: 150,
                hideLabel: true
            }
         },
        {
            border: false,
            xtype:'fieldset',
            rowspan: 2,
            title: 'Warranty',
            autoHeight:true,
            defaults: {width: 210},
            items :
            {
                xtype:'textarea',
                fieldLabel: 'Warranty',
                name: 'warranty',
                width: 400,
                height: 150,
                hideLabel: true
            }
         },
        {
            border: false,
            xtype:'fieldset',
            rowspan: 2,
            title: 'Overview',
            autoHeight:true,
            defaults: {width: 210},
            items :
            {
                xtype:'textarea',
                fieldLabel: 'Overview',
                name: 'overview',
                width: 400,
                height: 150,
                hideLabel: true
            }
         },
        {
            border: false,
            xtype:'fieldset',
            rowspan: 2,
            title: 'Features Desc',
            autoHeight:true,
            defaults: {width: 210},
            items :
            {
                xtype:'textarea',
                fieldLabel: 'Features Desc',
                name: 'features_desc',
                width: 400,
                height: 150,
                hideLabel: true
            }
         }

],
         buttons: [{
                    text: 'Save',
                    handler: function() {
                        this.getForm().submit({url: '/products/'+product_id+'/specs', waitMsg: 'Updating Info ...', method: "POST"});
                    },
                    scope: this
         }]
    }); 

    this.getForm().load();

};

Ext.extend(SpecsView, Ext.FormPanel, {
});