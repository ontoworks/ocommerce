/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

ShippingGrid = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    this.Shipping = Ext.data.Record.create([
           {name: 'name', type: 'string'},
           {name: 'from-weight', type: 'int'},
           {name: 'upto-weight', type: 'int'},
           {name: 'active', type: 'boolean'}
    ]);

    this.ShippingOption = Ext.data.Record.create([
           {name: 'option', type: 'string'},
           {name: 'active', type: 'boolean'},
           {name: 'international', type: 'boolean'}
    ]);

    this.store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: 'shipping.xml',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'shipping-module',
              id: 'id'
           }, this.Shipping),

        sortInfo:{field:'name', direction:'ASC'}
    });

    this.options_st = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/shipping/options/',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'shipping-option',
              id: 'id'
           }, this.ShippingOption),

        sortInfo:{field:'option', direction:'ASC'}
    });
    this.tbar = [
    ];

    this.columns = [{
        id: 'name',
        header: "Name",
        dataIndex: 'name',
        sortable:true,
        width: 200
      },{
        id: 'name2',
        header: "From Weight",
        align: 'right',
        dataIndex: 'from-weight',
        width: 50
      },{
        header: "Upto Weight",
        dataIndex: 'upto-weight',
        align: 'right',
        width: 50
    },{
        header: "Active?",
        dataIndex: 'active',
        align: 'center',
        width: 50,
        editor: new Ext.form.Checkbox(),
        tooltip: "Click to edit"
    }];

    this.options_cm = new Ext.grid.ColumnModel([
        {header: "Option Name", dataIndex: "option", width: 200},
        {header: "Active?", dataIndex: 'active', width: 50},
        {header: "International?", dataIndex: 'international', width: 50}
    ]);

    this.options_grid = new Ext.grid.EditorGridPanel({
        title: "Shipping Options for ",
        cm: this.options_cm,
        store: this.options_st,
        id: 'options-grid',
        region: 'south',
        loadMask: {msg:'Loading Options...'},

        viewConfig: {
            forceFit:true
        }
    });

    ShippingGrid.superclass.constructor.call(this, {
        clicksToEdit:1,
        region: 'center',
        id: 'ship-grid',
        loadMask: {msg:'Loading Shipping Modules...'},
 
        sm: new Ext.grid.RowSelectionModel({
            singleSelect:true
        }),

        viewConfig: {
            forceFit:true
        }
    });

    this.gsm = this.getSelectionModel();
    this.gsm.on('rowselect', function (sm, index, record) {
        this.options_grid.setTitle("Shipping Options for "+record.data.name);
        this.options_grid.store.load({params: {id: record.id}});
    }, this);
};

Ext.extend(ShippingGrid, Ext.grid.EditorGridPanel, {
    loadFeed : function(url) {
//        this.store.baseParams = {
//            feed: url
//        };
        this.store.load();
    }
});