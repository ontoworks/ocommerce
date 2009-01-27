/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

Ext.onReady(function(){
    Ext.QuickTips.init();

    var product_id = 0;
    this.contentView = {};
    var existsContentView = false;


    // shorthand alias
    var fm = Ext.form;

    // create the row expander for grid
    var content_view_cm = {
            header: "",
            width: 20,
            sortable: false,
            fixed:true,
            dataIndex: '',
            id: 'expander',
            lazyRender : true,
            enableCaching: true,
            renderer : function(v, p, record) {
                                   p.cellAttr = 'rowspan="2"';
                                   return '<div class="x-grid3-row-expander">&#160;</div>';
                       }
    };

    // the column model has information about grid columns
    // dataIndex maps the column to the specific data field in
    // the data store (created below)
    var cm = new Ext.grid.ColumnModel([
        content_view_cm,
        {
           id:'name',
           header: "Name",
           dataIndex: 'name',
           width: 450,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: "Model",
           dataIndex: 'model',
           width: 100,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: "Condition",
           dataIndex: 'condition',
           width: 100,
           editor: new Ext.form.ComboBox({
               typeAhead: true,
               triggerAction: 'all',
               transform:'condition',
               lazyRender:true,
               fieldLabel: "Condition",
               listClass: 'x-combo-list-small'
            })
        },{
           header: "Status",
           dataIndex: 'status',
           width: 70,
           align: "center",
           editor: new Ext.form.ComboBox({
               typeAhead: true,
               triggerAction: 'all',
               transform:'status',
               lazyRender:true,
               listClass: 'x-combo-list-small'
            })
        },{
           header: "Weight",
           dataIndex: 'weight',
           width: 70,
           renderer: weight,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: "Customer",
           dataIndex: 'customer-price',
           width: 70,
           renderer: money,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: "Business",
           dataIndex: 'business-price',
           width: 70,
           renderer: money,
           editor: new fm.TextField({
               allowBlank: false
           })
        },{
           header: "Wholesale",
           dataIndex: 'wholesale-price',
           width: 70,
           renderer: money,
           editor: new fm.TextField({
               allowBlank: false
           })
        }
    ]);

    // by default columns are sortable
    cm.defaultSortable = true;

    // this could be inline, but we want to define the Plant record
    // type so we can add records dynamically
    var Product = Ext.data.Record.create([
           {name: 'name', type: 'string'},
           {name: 'description', type: 'string'},
           {name: 'model', type: 'string'},
           {name: 'condition'},
           {name: 'weight', type: 'float'},
           {name: 'status'},
           {name: 'customer-price', type: 'float'},
           {name: 'business-price', type: 'float'},
           {name: 'wholesale-price', type: 'float'}
      ]);

    // create the Data Stores
    // grid store
    var grid_store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: 'products.xml',
              method: 'GET'
        }),

        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
              totalRecords: 'totalCount',
              record: 'product',
              id: 'id'
           }, Product),

        sortInfo:{field:'status', direction:'DESC'}
    });

    // saves data to the cell level
    var save_store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: 'products/save_cell.xml',
              method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'id'
           }, [])
    });

    // saves data to the cell level
    var search_store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: 'products/save_cell.xml',
              method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'id'
           }, [])
    });

    // brings a new draft production for editing
    var draft_store = new Ext.data.Store({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({
              url: 'products/draft.xml',
              method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'product'
           }, [])
    });

    // perPage objects
    PerPageData = [
        ['10',  '10'],
        ['25',  '25'],
        ['50',  '50'],
        ['100', '100']
    ];

    var ppstore = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : PerPageData
    });

    var perPage = new Ext.form.ComboBox({
		store: ppstore,
        displayField:'txt',
        typeAhead: true,
        mode: 'local',
        triggerAction: 'all',
        selectOnFocus:true,
        resizable:true,
        listWidth: 50,
        width: 50,
        value: '25'
    });


    // let us set up our grid
    this.gridView = {};

    // menu actions
    var showKits = new Ext.Action({
        text: 'Kits',
        handler: showKits,
        iconCls: 'blist'
    });

    var showSpecs = new Ext.Action({
        text: 'Specs',
        handler: showSpecsTabs,
        iconCls: 'blist'
    });

    var showRelatedProducts = new Ext.Action({
        text: 'Related Products',
        handler: showRelatedProducts,
        iconCls: 'blist'
    });

    var showProductInfo = new Ext.Action({
        text: 'Product Info',
        handler: showProductInfo,
        iconCls: 'blist'
    });

    var showWarranties = new Ext.Action({
        text: 'Warranties',
        handler: showWarranties,
        iconCls: 'blist'
    });


    var search_by_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['1', 'Multifunction Printers'],
        ['2', 'Cables'],
        ['3', 'Digital Senders'],
        ['4', 'Dot Matrix Printers'],
        ['5', 'Fuser and Maintenance Kits'],
        ['6', 'Hard Disks'],
        ['7', 'Ink and Toners Cartridges'],
        ['10', 'Laser Printers'],
        ['11', 'Memory modules'],
        ['12', 'Network Cards'],
        ['13', 'Parts'],
        ['14', 'Plotters'],
        ['16', 'Sheet Feeders'],
        ['209', 'Printer and Plotter Paper'],
        ['217', 'Color Laser Printers'],
        ['223', 'Paper Handling']]
    });

    var search_by_combo = new Ext.form.ComboBox({
        store: search_by_st,
        width: 150,
        displayField:'txt',
        selectOnFocus:true,
        mode: 'local',
        typeAhead: false,
        triggerAction: 'all',
        listClass: 'x-combo-list-small'
//      pageX: 40,
//      pageY: 60
    });

    search_by_combo.on("select", searchBy, this);
    function searchBy(combo, record, index) {
        grid_store.baseParams = {category_id: record.data.num};
        grid_store.load({params:{offset:0, limit:25}});
//        grid_store.load({params:{category_id: record.data.num, offset:0, limit:25}});
    }

    // create the editor grid
    var grid = new Ext.grid.EditorGridPanel({
        el:'editor-grid',
        store: grid_store,
        cm: cm,
        width:1000,
        height:700,
        autoExpandColumn:'name',
        title:'Edit Products?',
        trackMouseOver:false,
        sm: new Ext.grid.RowSelectionModel({selectRow:Ext.emptyFn}),
        loadMask: true,
        viewConfig: {
			forceFit:true,
			enableRowBody:true,
			showPreview:true,
			getRowClass: function(record, rowIndex, p, store){
				if (record.data.status == "N") {
					return "active";
				}
				if (record.data.status == "D") {
					return "draft";
				}
			}
		},
        clicksToEdit:1,

        tbar: new Ext.Toolbar({ items:
            ['Search: ',
                new Ext.app.SearchField({
                  store: grid_store,
                  width:320
         }),' ','-',' ','Category:',
         search_by_combo,' ','-',' ',
         { id: 'add_product_btn',
           text: 'Add Product',
           handler: addNewRow
         },{
            id: 'product_btn',
            text: 'Product',
            menu: [showProductInfo, showRelatedProducts, showKits, showSpecs, showWarranties],
            hidden: true
         },{
            id: 'restore_btn',
            text: '<< Back to search',
            hidden: true,
            handler: restoreGrid
        }]}),

        bbar: new Ext.PagingToolbar({
            pageSize: 25,
            store: grid_store,
            paramNames: {start: 'offset', limit: 'limit'},
            displayInfo: true,
            displayMsg: 'Displaying products {0} - {1} of {2}',
            emptyMsg: "No products to display",
            items:['-', "Per page", perPage,'-']
      })
    });

    var grid_view = grid.getView();

    // our listeners
    // whenever a cell is edited call afterEdit
    grid.on("afteredit", afterEdit);
    grid.on("render", function(){
              grid_view.mainBody.on('mousedown', onMouseDown, this);
    }, this);

    // trigger the data store load
    grid_store.load({params:{offset:0, limit:25}});

    grid.render();

    // get div corresponding to this grid's GridView
    var gridView = grid.body.child(".x-grid3");
    // add content view grid
//    var contentView = addContentView();

    var paging = grid.getBottomToolbar();

    draft_store.on("load", storeUpdate);
    perPage.on("select", setPerPage);

    function showProductInfo() {
        if (existsContentView) {
            grid.body.child(".x-content").remove();
            existsContentView = false;
        }
        new ContentView(product_id, addContentView());
    }

    function showRelatedProducts() {
        if (existsContentView) {
            grid.body.child(".x-content").remove();
            existsContentView = false;
        }
        new RelatedProducts(product_id, addContentView());
    }

    function showSpecsTabs() {
        if (existsContentView) {
            grid.body.child(".x-content").mask();
            //            existsContentView = false;
        }
        var specs = new SpecsViewer(product_id);
        specs.show();
        specs.on("close", function() {
            grid.body.child(".x-content").unmask();
        }, this);
    }

    function showKits() {
        if (existsContentView) {
            grid.body.child(".x-content").remove();
            existsContentView = false;
        }
        new KitsView(product_id, addContentView());
    }

    function showWarranties() {
        if (existsContentView) {
            grid.body.child(".x-content").remove();
            existsContentView = false;
        }
        new WarrantyPanel(product_id, addContentView());
    }

    function addContentView() {
        var content_view = new Ext.Element(document.createElement("div"));
        content_view.addClass("x-content");
        content_view.applyStyles({ width: "998px", height: "620px",
                                          overflow: "hidden", position: "relative" });

        grid.body.appendChild(content_view);

        Ext.getCmp('restore_btn').show();
        Ext.getCmp('product_btn').show();
        Ext.getCmp('add_product_btn').hide();

        var tbar = grid.getTopToolbar();
        tbar.items.get(0).hide();
        tbar.items.get(1).hide();
        tbar.items.get(2).hide();
        tbar.items.get(3).hide();
        tbar.items.get(4).hide();
        tbar.items.get(5).hide();
        tbar.items.get(6).hide();

        existsContentView = true;

        return content_view;
    }

    function restoreGrid(){
        grid.body.child(".x-content").remove();
        grid.body.child(".x-grid3").setDisplayed(true);
        grid.bbar.show();
        Ext.getCmp('add_product_btn').show();
        Ext.getCmp('product_btn').hide();
        Ext.getCmp('restore_btn').hide();

        var tbar = grid.getTopToolbar();
        tbar.items.get(0).show();
        tbar.items.get(1).show();
        tbar.items.get(2).show();
        tbar.items.get(3).show();
        tbar.items.get(4).show();
        tbar.items.get(5).show();
        tbar.items.get(6).show();

        existsContentView = false;
    }

    function onMouseDown(e, t) {
        if (t.className == 'x-grid3-row-expander') {
            e.stopEvent();
            var row = e.getTarget('.x-grid3-row');

            if (typeof row == 'number'){
               row = grid_view.getRow(row);
            }

            var record = grid_store.getAt(row.rowIndex);

            grid.body.child(".x-grid3").setDisplayed(false);
            grid.bbar.hide();

            product_id = record.id;

            new ContentView(product_id, addContentView());
        }
    }

    function addProduct() {
    }

    function addNewRow() {
        var p = new Product({
           'name': 'Enter Product Name',
           'description': 'Description',
           'model': 'Model',
           'condition': 'New',
           'weight': '0',
           'status': 'D',
           'customer-price': 0,
           'business-price': 0,
           'wholesale-price': 0
        }, 0);
        grid.stopEditing();
        grid_store.insert(0, p);
        grid.startEditing(0, 0);
    }

    function storeUpdate(store, record, operation) {
        root = store.reader.xmlData; // has xmlDocument object
        var q = Ext.DomQuery;
        var id = q.selectNumber("id", root, 0);
        product_id = id;
        grid_store.getAt(0).id = id;
    }

    // if a new/draft record, load draft_store.
    // when an onLoad event happens to draft_store
    // storeUpdate is called to assign id to new/draft record
    function afterEdit(e) {
        record = e.record;
        if (record.id == 0) {
              draft_store.load({params: {field: e.field, value: e.value}});
        } else {
              save_store.load({params: {field: e.field, id: e.record.id, value: e.value}});
        }
    }

    function setPerPage() {
        if (perPage.getValue() != 'ALL') {
                paging.pageSize = parseInt(perPage.getValue());
        } else {
                paging.pageSize = store.getTotalCount();
        }
        paging.cursor = 0;
        grid_store.load({params:{offset: paging.cursor, limit: paging.pageSize}});
    }

    function money(value) {
        return "$"+value;
    }

    function weight(value) {
        return value+" lb";
    }
});