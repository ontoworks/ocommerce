/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

WarrantyGrid = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    var Warranty = Ext.data.Record.create([
           {name: 'title'},
           {name: 'context'},
           {name: 'product', type: 'int'},
           {name: 'category'},
           {name: 'price'}
    ]);

    this.store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/warranties.xml',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'warranty',
              id: 'id'
           }, Warranty),

        sortInfo:{field:'context', direction:'ASC'}
    });

    this.tbar = [
        {  id: 'add_warranty_btn',
           text: 'New Warranty',
           handler: addNewRow,
           scope: this
        },' ','-',' ',{  id: 'remove_warranty_btn',
           text: 'Remove Warranty',
           handler: removeWarranty,
           scope: this
        }];

    var contextSelect = [
        ["default","default"],
        ["product","product"],
        ["category","category"]
    ];

    var context_combo = new Ext.form.ComboBox({
        name: "context",
        fieldLabel: "context",
        listclass: 'x-combo-list-small',
        store: new Ext.data.SimpleStore({
            fields: ['id', 'name'],
            data : contextSelect
        }),
        displayField:'name',
        typeAhead: true,
        mode: 'local',
        triggerAction: 'all',
        selectOnFocus:true
    });

    var sm = new Ext.grid.CheckboxSelectionModel();
    this.columns = [sm, {
        id: 'title',
        header: "Title",
        dataIndex: 'title',
        sortable:true,
        width: 300,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
      },{
        id: 'price',
        header: "Price",
        dataIndex: 'price',
        width: 100,
        renderer: money,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
      },{
        id: 'context',
        header: "Context",
        dataIndex: 'context',
        width: 75,
        hidden: true,
        editor: context_combo
      },{
        id: 'category',
        header: "Category",
        dataIndex: 'category',
        width: 110,
        hidden: true,
        editor: context_combo
    }];

    context_combo.on("change", function(field, newValue, oldValue) {
        var category_index = this.getColumnModel().getIndexById('category')
        switch(newValue) {
        case "category":
            this.getColumnModel().setHidden(category_index, false);
            this.preview.disable();
            break;
        case "product":
            this.getColumnModel().setHidden(category_index, true);
            this.preview.enable();
            break;
        default:
            this.getColumnModel().setHidden(category_index, true);
            this.preview.disable();
            break;
        }
    }, this);

    this.search_sm = new Ext.grid.CheckboxSelectionModel({singleSelect:true});

    this.search_cm = new Ext.grid.ColumnModel([
        this.search_sm,
        {
           id:'name',
           header: "Name",
           dataIndex: 'name',
           width: 400
        },{
           header: "Model",
           dataIndex: 'model',
           width: 100
        }
    ]);

    var Product = Ext.data.Record.create([
           {name: 'name', type: 'string'},
           {name: 'model', type: 'string'}
    ]);

    var search_store = new Ext.data.Store({
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

        sortInfo:{field:'name', direction:'DESC'}
    });

    this.preview = new Ext.grid.GridPanel({
        cm: this.search_cm,
        sm: this.search_sm,
        region: 'south',
        store: search_store,
        id: 'preview',
        cls:'preview',
        autoScroll: true,
        viewConfig: {
            forceFit:true
        },
/*        tbar: [
           'Search for products: ',
            new Ext.app.SearchField({
                store: search_store,
                 width:200
            }),{
            id:'add',
            text: 'Add selected to this Kit',
            iconCls: 'new-tab',
            disabled:true,
            handler : this.openTab,
            scope: this
        },'-',{
            id:'copy',
            text: 'Copy this Kit to selected',
            iconCls: 'new-win',
            disabled:true,
            scope: this,
            handler : function(){
                window.open(this.gsm.getSelected().data.link);
            }
        }

        ] */
    });

    this.preview.disable();

    WarrantyGrid.superclass.constructor.call(this, {
        clicksToEdit:1,
        region: 'center',
        id: 'warranty-grid',
        loadMask: {msg:'Loading Shipping Modules...'},
        sm: sm, 
        viewConfig: {
//            forceFit:true
        }
    });

    var save_store = new Ext.data.Store({
        // load using HTTP
	proxy: new Ext.data.HttpProxy({
              url: 'warranties',
	      method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'warranty'
           }, [])
    });

    var new_store = new Ext.data.Store({
        // load using HTTP
	proxy: new Ext.data.HttpProxy({
              url: 'warranties',
	      method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'warranty'
           }, [])
    });

    new_store.on("load", storeUpdate, this);

    this.on("afterEdit", afterEdit, this);

    function removeWarranty() {
        var selected = sm.getSelections();
        for (var i = 0; i < selected.length; i++) {
            this.store.remove(selected[i]);
            var proxy = new Ext.data.HttpProxy({
                url: '/warranties/'+selected[i].id+'.xml',
                method: 'DELETE'
            });
            proxy.load();
        }
    }

    function afterEdit(e) {
	record = e.record;
	if (record.id == 0) {
            alert("new record");
	    new_store.load({params: {field: e.field, value: e.value}});
	} else {
            var proxy = new Ext.data.HttpProxy({
                url: 'warranties/'+record.id+'.xml',
	        method: 'PUT'})
            proxy.load({field: e.field, value: e.value});
	}
    }

    function addNewRow() {
        new_store.load({params: {title: 'Enter Warranty Name', 
                                 context: 'default', 
                                  price: 0}});
    }

    function storeUpdate(store, record, operation) {
	root = store.reader.xmlData;
        var q = Ext.DomQuery;
	var id = q.selectNumber("id", root, 0);

        var p = new Warranty({
            'title': 'Enter Warranty Name',
            'context': 'default',
            'price': 0
        }, id);

        this.stopEditing();
        this.store.insert(0, p);
        this.startEditing(0, 0);
    }

    function money(value) {
        return "$"+value;
    }

    this.gsm = this.getSelectionModel();
    this.gsm.on('rowselect', function (sm, index, record) {
        var category_index = this.getColumnModel().getIndexById('category');

        this.getColumnModel().setHidden(category_index, true);
        this.preview.disable();
   
        switch (record.data.context) {
        case "category":
            this.getColumnModel().setHidden(category_index, false);
            break;
        case "product":
            this.preview.enable();
            break;
        default:
            break;
        }
    }, this); 
};

Ext.extend(WarrantyGrid, Ext.grid.EditorGridPanel, {
//Ext.extend(WarrantyGrid, Ext.Panel, {
    loadFeed : function(url) {
//        this.store.baseParams = {
//            feed: url
//        };
        this.store.load();
    }
});