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

    var product_id = 0;
    this.prod_id = 0;
    this.selected_kit = 0;
    this.selected_type = 0;
    this.selected_price = 0;

    this.kitPrice = "";

    this.Product = Ext.data.Record.create([
        {name: 'name', type: 'string'},
        {name: 'model', type: 'string'}
    ]);

    this.store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'product',
              id: 'id'
           }, this.Product),
        sortInfo:{field:'name', direction:'DESC'}
    });

    this.columns = [{
        id: 'name',
        header: "Product Name",
        dataIndex: 'name',
        sortable:true,
        renderer: this.formatTitle
    }];

    this.image_view = new Ext.Panel({
        bbar: new Ext.Toolbar({
        }),
        bodyStyle:'background:white; padding:5px 5px 0;',
        title: "Kit image",
        border: false,
        region: 'center'
    });

    FeedGrid.superclass.constructor.call(this, {
        region: 'center',
        id: 'topic-grid',
        loadMask: {msg:'Loading Feed...'},

        sm: new Ext.grid.RowSelectionModel({
            singleSelect:true
        }),

        viewConfig: {
            forceFit:true,
            enableRowBody:true,
            showPreview:true,
            getRowClass : this.applyRowClass
        }
    });
};

Ext.extend(FeedGrid, Ext.grid.GridPanel, {
    removeProduct: function(selected_kit, product_id) {
        var proxy = new Ext.data.HttpProxy({
            url: '/kits/remove_products',
            extraParams: {id: selected_kit, product_id: product_id}
        });
        proxy.load();
    },

    setSelectedKit: function(kit_id) {
        this.selected_kit = kit_id;
    },

    loadFeed : function(kit) {
        this.selected_type = kit.type;
        this.selected_kit = kit.kit_id;
        //        this.selected_price = kit.price;

        var price_text = Ext.ComponentMgr.get("price");
        //        price_text.setValue(kit.price);
        //this.kitPrice = kit.price;
        price_text.setValue(this.kitPrice);

        if (kit.kit_id > 0) {
            this.store.proxy = new Ext.data.HttpProxy({
                url: '/kits/'+kit.kit_id+'/products',
                method: 'GET'
            });

            this.image_view.load('/kits/'+this.selected_kit+'/image');

            this.store.load();
       } else {
            // esta es una solucion temporal para limpiar el contenido del panel
            // cuando tiene algo adentro. El backend redirige a pagina vacia
            // cuando kit_id es 0
            this.image_view.load('/kits/'+this.selected_kit+'/image');
            this.store.removeAll();
       }
    }
});