/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

BrandGrid = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    var Brand = Ext.data.Record.create([
           {name: 'name'},
           {name: 'products-count', type: 'int'}
    ]);

    this.store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: '/brands.xml',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'brand',
              id: 'id'
           }, Brand),

        sortInfo:{field:'name', direction:'ASC'}
    });

    this.tbar = [
        {  id: 'add_brand_btn',
           text: 'New Brand',
           handler: addNewRow,
           scope: this
        },' ','-',' ',{  id: 'remove_brand_btn',
           text: 'Remove Brand',
           handler: removeRow,
           scope: this
        }];

    var sm = new Ext.grid.CheckboxSelectionModel();
    this.columns = [sm, {
        id: 'name',
        header: "Name",
        dataIndex: 'name',
        sortable:true,
        width: 200
	},{
        header: "Products count",
        dataIndex: 'products-count',
        sortable:true,
        width: 100
      }];

    BrandGrid.superclass.constructor.call(this, {
        clicksToEdit:1,
        region: 'center',
        id: 'brand-grid',
        loadMask: {msg:'Loading Shipping Modules...'},
        sm: sm, 
        viewConfig: {
//            forceFit:true
        }
    });

    var save_store = new Ext.data.Store({
        // load using HTTP
	proxy: new Ext.data.HttpProxy({
              url: 'brands',
	      method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'brand'
           }, [])
    });

    var new_store = new Ext.data.Store({
        // load using HTTP
	proxy: new Ext.data.HttpProxy({
              url: 'brands',
	      method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'brand'
           }, [])
    });

    new_store.on("load", storeUpdate, this);

    this.on("afterEdit", afterEdit, this);

    function removeRow() {
        var selected = sm.getSelections();
        for (var i = 0; i < selected.length; i++) {
            this.store.remove(selected[i]);
            var proxy = new Ext.data.HttpProxy({
                url: '/brands/'+selected[i].id+'.xml',
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
                url: 'brands/'+record.id+'.xml',
	        method: 'PUT'})
            proxy.load({field: e.field, value: e.value});
	}
    }

    function addNewRow() {
        new_store.load({params: {title: 'Enter Brand Name', 
                                 context: 'default', 
                                  price: 0}});
    }

    function storeUpdate(store, record, operation) {
	root = store.reader.xmlData;
        var q = Ext.DomQuery;
	var id = q.selectNumber("id", root, 0);

        var p = new Warranty({
            'name': 'Enter Brand Name'
        }, id);

        this.stopEditing();
        this.store.insert(0, p);
        this.startEditing(0, 0);
    }
};

Ext.extend(BrandGrid, Ext.grid.EditorGridPanel, {
//Ext.extend(WarrantyGrid, Ext.Panel, {
    loadFeed : function(url) {
//        this.store.baseParams = {
//            feed: url
//        };
        this.store.load();
    }
});