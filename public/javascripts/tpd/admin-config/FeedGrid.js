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

    var group_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['customer', 'customer'], ['business', 'business'], ['wholesale', 'wholesale']]
    });

    var search_by = "lastname";

    var search_by_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['firstname', 'First Name'], ['lastname', 'Last Name'], ['email', 'Email']]
    });

    var search_by_combo = new Ext.form.ComboBox({
        store: search_by_st,
        width: 90,
        displayField:'txt',
        selectOnFocus:true,
        mode: 'local',
        typeAhead: false,
        triggerAction: 'all',
        listClass: 'x-combo-list-small'
    });

    var User = Ext.data.Record.create([
           {name: 'firstname', type: 'string'},
           {name: 'lastname', type: 'string'},
           {name: 'email', type: 'string'},
           {name: 'usergroup', type: 'string'}
    ]);

    this.store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: 'users.xml',
            method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              totalRecords: 'totalCount',
              record: 'user',
              id: 'id'
           }, User),

        baseParams: {search_by: search_by},

        sortInfo:{field:'firstname', direction:'ASC'}
    });

    function setSearchBy(combo, record, index) {
        search_by = record.data.num;
        this.store.baseParams = { search_by: search_by }
    }

    search_by_combo.on("select", setSearchBy, this);
    search_by_combo.setValue("Last Name");

    this.store.on("beforeload", function() {
//        alert(search_by);
    }, this);


    this.tbar = ['Search: ',
                new Ext.app.UserSearchField({
                  store: this.store,
                  width:200
         }),' ',' By:',
         search_by_combo, 
         '  ','-',' '
/*         ,{
            text: 'New user',
            handler: newUser,
            scope: this
        } */
         ];

    this.columns = [{
        id: 'firstname',
        header: "First Name",
        dataIndex: 'firstname',
        sortable:true,
        width: 120
//        ,editor: new Ext.form.TextField({
//            allowBlank: false
//        })
      },{
        header: "Last Name",
        dataIndex: 'lastname',
        width: 120,
        sortable:true
//        ,editor: new Ext.form.TextField({
//            allowBlank: false
//        })
      },{
        id: 'email',
        header: "Email",
        dataIndex: 'email',
        width: 220,
        sortable:true
//        ,editor: new Ext.form.TextField({
//            allowBlank: false
//        })
    },{
        id: 'usergroup',
        header: "Group",
        dataIndex: 'usergroup',
        width: 100,
        sortable:true,
        editor: new Ext.form.ComboBox({
            store: group_st,
            displayField:'txt',
            selectOnFocus:true,
            mode: 'local',
            typeAhead: true,
            triggerAction: 'all',
            listClass: 'x-combo-list-small'
        })
    }];

    var save_store = new Ext.data.Store({
        // load using HTTP
	proxy: new Ext.data.HttpProxy({
              url: 'users/save_cell.xml',
	      method: 'POST'
        }),

        reader: new Ext.data.XmlReader({
              record: 'id'
           }, [])
    });

    function afterEdit(e) {
	record = e.record;
	if (record.id == 0) {
	      draft_store.load({params: {field: e.field, value: e.value}});
	} else {
	      save_store.load({params: {field: e.field, id: e.record.id, value: e.value}});
	}
    }

    function newUser() {
	var u = new User({
                              firstname: "New User",
                              lastname: "",
                              email: "",
                              usergroup: ""
                             }, 0);
        this.stopEditing();
        this.store.insert(0, u);
        this.startEditing(0, 0);
    }

    FeedGrid.superclass.constructor.call(this, {
        clicksToEdit:1,
        region: 'center',
        id: 'topic-grid',
        loadMask: {msg:'Loading Feed...'},
        width: 600
    });

    this.on("afteredit", afterEdit);
};

Ext.extend(FeedGrid, Ext.grid.EditorGridPanel, {
    loadFeed : function(url) {
        this.store.load();
    }
});