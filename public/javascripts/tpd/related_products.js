

RelatedProducts = function(product_id, contentView){
    this.contentView = contentView;

    var Product = Ext.data.Record.create([
        {name: 'name', type: 'string'},
        {name: 'model', type: 'string'},
        {name: 'condition'},
        {name: 'status'},
        {name: 'cross-sell-group'},
        {name: 'manufacturer-id', type: 'int'}
    ]);

    var search_store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: '/products.xml',
              method: 'GET'
        }),

        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
              record: 'product',
              id: 'id'
           }, Product),

        sortInfo:{field:'status', direction:'DESC'}
    });

    var group_store = new Ext.data.GroupingStore({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: '/products/cross_sells_and_cross_sellers/'+product_id+'.xml',
              method: 'GET'
        }),

        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
              record: 'product',
              id: 'id'
           }, Product),

        groupField: "cross-sell-group",
        remoteGroup: true,
        remoteSort: true,
        sortInfo:{field:'name', direction:'DESC'}
    });

    sm = new Ext.grid.CheckboxSelectionModel();
    sm2 = new Ext.grid.CheckboxSelectionModel();

    cm = new Ext.grid.ColumnModel([
        sm,
        {
           id:'name',
           header: "Name",
           dataIndex: 'name',
           width: 400
        },{
           header: "Model",
           dataIndex: 'model',
           width: 100
        },{
           header: "XS Type",
           dataIndex: 'cross-sell-group',
           width: 100,
           hidden: true
        }
    ]);

    cm2 = new Ext.grid.ColumnModel([
        sm2,
        {
           id:'name',
           header: "Name",
           dataIndex: 'name',
           width: 450
        },{
           header: "Model",
           dataIndex: 'model',
           width: 100
        }
    ]);

    this.xseller_grid = new Ext.grid.GridPanel({
//        el: 'xseller_panel',
        id:'xseller-grid',
        split: true,
        store: group_store,
        cm: cm,
        sm: sm,

        view: new Ext.grid.GroupingView({
            forceFit:true,
            emptyGroupText: 'No products in this group',
            groupTextTpl: '{group}s ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
        }),

        tbar:[{
            text:'Remove Product(s)',
            tooltip:'Remove the selected product(s)',
            iconCls:'remove',
            handler: remove,
            scope: this
        }],

        width:600,
        height:300,
        frame:true,
//        title:'Products that cross-sell and are cross-selled by '+product_name,
        title:'Products that cross-sell and are cross-selled by ',
        iconCls:'icon-grid'
    });

    this.search_grid = new Ext.grid.GridPanel({
//        el: 'search_panel',
        id:'search-grid',
        store: search_store,
        cm: cm2,
        sm: sm2,

        viewConfig: {
            forceFit:true
        },

        // inline buttons
        buttons: [{ text:'Add as cross-sell', handler: add_as_cross_sell, scope: this
                 },{ text: 'Add as cross-seller', handler: add_as_cross_seller, scope: this }
        ],
        buttonAlign:'center',

        // inline toolbars
        tbar:['Search: ',
               new Ext.app.SearchField({
                  store: search_store,
                  width:320
               })        
        ],

        width:600,
        height:200,
        frame:true,
        title:'Search for products',
        iconCls:'icon-grid'
    });

    group_store.load();
    group_store.on("add", save);
//    function addEvent() { alert("Here")};

//    xseller_grid.render();
//    search_grid.render();

      RelatedProducts.superclass.constructor.call(this, {
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
             items: [this.xseller_grid, this.search_grid]
         }]
    });

    function add_as_cross_seller() {
        add_record("Cross Seller");
    }

    function add_as_cross_sell() {
        add_record("Cross Sell");
    }

    function add_record(group) {
        var selected = sm2.getSelections();
        for (var i = 0; i < selected.length; i++) {
            var record = group_store.getById(selected[i].id);
            if (Ext.type(record)) {
                if (record.get("cross-sell-group") == group) {
                //    alert("Already There");
                    break;
                } else {
                }
            }
        //    alert("Insert or Change Group");
            selected[i].set("cross-sell-group", group);
            group_store.add(selected[i]);
        }
    }

    function remove() {
        var selected = sm.getSelections();
        for (var i = 0; i < selected.length; i++) {
            var url = '/products/'+product_id;
            if (selected[i].get("cross-sell-group") == "Cross Sell") {
                url += '/cross_sells/'+selected[i].id
            } else if (selected[i].get("cross-sell-group") == "Cross Seller") {
                url += '/cross_sellers/'+selected[i].id
            }
            group_store.remove(selected[i]);
            var proxy = new Ext.data.HttpProxy({
                url: url,
                method: 'DELETE'
            });
            proxy.load();
        }
    }

    function save(store, r, index) {
        var url = '/products/';

        for (var i = 0; i < r.length; i++) {
            if (r[i].get("cross-sell-group") == "Cross Sell") {
                url += 'cross_sells/';
            }

            if (r[i].get("cross-sell-group") == "Cross Seller") {
                url += 'cross_sellers/';
            }

            var proxy = new Ext.data.HttpProxy({
                url: url,
                method: 'POST'
            });

            proxy.load({id: product_id, product_id: r[i].id});
        }
    }
};

Ext.extend(RelatedProducts, Ext.Panel, {
});