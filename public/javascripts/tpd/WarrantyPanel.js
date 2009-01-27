

WarrantyPanel = function(product_id, contentView){
    this.contentView = contentView;

    var Warranty = Ext.data.Record.create([
        {name: 'title', type: 'string'},
        {name: 'price', type: 'float'},
        {name: 'context'},
    ]);

    var list_store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: '/warranties.xml',
              method: 'GET'
        }),

        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
              record: 'warranty',
              id: 'id'
           }, Warranty),

        sortInfo:{field:'price', direction:'DESC'}

    });

    list_store.load();

    this.store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: '/products/'+product_id+'/warranties',
              method: 'GET'
        }),

        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
              record: 'warranty',
              id: 'id'
           }, Warranty),

        sortInfo:{field:'price', direction:'DESC'}
    });

    var sm = new Ext.grid.CheckboxSelectionModel();
    var sm2 = new Ext.grid.CheckboxSelectionModel();

    var cm = new Ext.grid.ColumnModel([
        sm,
        {
           id:'title',
           header: "Name",
           dataIndex: 'title',
           width: 400
        },{
           header: "Price",
           dataIndex: 'price',
           width: 100
        }
    ]);

    var cm2 = new Ext.grid.ColumnModel([
        sm2,
        {
           id:'title',
           header: "Name",
           dataIndex: 'title',
           width: 400
        },{
           header: "Price",
           dataIndex: 'price',
           width: 100
        }
    ]);

    this.active_warranties = new Ext.grid.GridPanel({
        id:'active-grid',
        split: true,
        store: this.store,
        cm: cm,
        sm: sm,

        tbar:[{
            text:'Remove Warranty',
            tooltip:'Remove the selected warranty',
            iconCls:'remove',
            handler: remove_warranty,
            scope: this
        }],

        width:600,
        height:300,
        frame:true,
        title:'Warranties active for ',
        iconCls:'icon-grid'
    });

    this.active_warranties.store.load();

    this.search_grid = new Ext.grid.GridPanel({
        id:'list-grid',
        store: list_store,
        cm: cm,
        sm: sm2,

        viewConfig: {
            forceFit:true
        },

        // inline buttons
        buttons: [{ text:'Add warranty', handler: add_warranty, scope: this
                 }
        ],
        buttonAlign:'center',

        width:600,
        height:200,
        frame:true,
        title:'Available Warranties',
        iconCls:'icon-grid'
    });

    WarrantyPanel.superclass.constructor.call(this, {
         bodyBorder: false,
         border: false,
         renderTo: this.contentView,
         layout: 'column',
         defaults: {
            border: false,
            bodyStyle: 'padding:6px'
         },

         viewConfig: {
            forceFit:true
         },

         items: [{
             rowspan: 2,
             items: [this.active_warranties, this.search_grid]
         }]
    });

    this.add_store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'warranty',
              id: 'id'
           }, Warranty),

        sortInfo:{field:'price', direction:'DESC'}
    })

    this.remove_store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({
              record: 'warranty',
              id: 'id'
           }, Warranty),

        sortInfo:{field:'price', direction:'DESC'}
    })

    function remove_warranty() {
        var selected = sm.getSelections();
        for (var i = 0; i < selected.length; i++) {
            this.store.remove(selected[i]);
            this.remove_store.proxy = new Ext.data.HttpProxy({
                url: '/products/'+product_id+'/warranties/'+selected[i].id,
                method: 'DELETE'
            })
            this.remove_store.load();
        }
    }

    function add_warranty() {
        var selected = sm2.getSelections();
        for (var i = 0; i < selected.length; i++) {
            this.store.add(selected[i]);
            this.add_store.proxy = new Ext.data.HttpProxy({
                url: '/products/'+product_id+'/warranties/'+selected[i].id,
                method: 'POST'
            })
            this.add_store.load({params: {i: '111'}});
        }
    }
};

Ext.extend(WarrantyPanel, Ext.Panel, {
});