

//SearchProduct = function() {
OrderGrid = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    var start = 0;
    var end = 0;
    var search_by = "id";

    this.Order = Ext.data.Record.create([
        {name: 'id', type: 'int'},
        {name: 'date'},
        {name: 'name', type: 'string'},
        {name: 'status', type: 'string'},
        {name: 'current-status', type: 'string'},
        {name: 'payment-method', type: 'string'},
        {name: 'shipping_method', type: 'string'},
        {name: 'shipping_approx', type: 'string'},
        {name: 'carrier', type: 'string'},
        {name: 'total', type: 'float'}
    ]);

    this.store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
              url: '/orders.xml',
              method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              totalRecords: 'totalCount',
              record: 'order',
              id: 'id'
           }, this.Order),

        sortInfo:{field:'id', direction:'DESC'}
    });

    this.sm = new Ext.grid.CheckboxSelectionModel({singleSelect:true});

    var status_combo = new Ext.form.ComboBox({
               typeAhead: true,
               triggerAction: 'all',
               transform:'status',
               lazyRender:true,
               fieldLabel: "Status",
               listClass: 'x-combo-list-small'
            });

    this.columns = [
        this.sm,
        {
           header: "#",
           dataIndex: 'id',
           width: 50
        },{
           id:'date',
           header: "Date",
           dataIndex: 'date',
           width: 80
        },{
           header: "Customer",
           dataIndex: 'name',
           width: 150,
           sortable: true
        },{
           id: 'status',
           header: "Status",
           dataIndex: 'current-status',
           width: 80,
           editor: status_combo
        },{
           header: "Payment",
           dataIndex: 'payment-method',
           width: 80
        },{
           header: "Shipping",
           dataIndex: 'carrier',
           width: 60,
           sortable: true
        },{
           header: "Total",
           dataIndex: 'total',
           width: 80,
           sortable: true,
           renderer: money
       }
    ];

    function money(value) {
        return "$"+value;
    }

    this.store.load({params:{offset:0, limit:25}});

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

    var paging = this.getBottomToolbar();
    perPage.on("select", setPerPage);
    function setPerPage() {
        if (perPage.getValue() != 'ALL') {
                paging.pageSize = parseInt(perPage.getValue());
        } else {
                paging.pageSize = store.getTotalCount();
        }
        paging.cursor = 0;
        this.store.load({params:{offset: paging.cursor, limit: paging.pageSize}});
    }

    var month_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['01', 'Jan'],
        ['02', 'Feb'],
        ['03', 'Mar'],
        ['04', 'Apr'],
        ['05', 'May'],
        ['06', 'Jun'],
        ['07', 'Jul'],
        ['08', 'Aug'],
        ['09', 'Sep'],
        ['10', 'Oct'],
        ['11', 'Nov'],
        ['12', 'Dec']]
    });

    var month_combo = new Ext.form.ComboBox({
        store: month_st,
        width: 50,
        displayField:'txt',
        selectOnFocus:true,
        mode: 'local',
        typeAhead: false,
        triggerAction: 'all',
        listClass: 'x-combo-list-small'
    });

    month_combo.on("select", function(combo, record, index) {
        this.store.baseParams = {date: record.data.num};
        this.store.load({params:{offset:0, limit:25}});
    }, this);

    var date_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['today', 'Today'],
        ['yesterday', 'Yesterday'],
                ['this_week', 'This Week'],
        ['this_month', 'This Month']]
    });

    var date_combo = new Ext.form.ComboBox({
        store: date_st,
        width: 100,
        displayField:'txt',
        selectOnFocus:true,
        mode: 'local',
        typeAhead: false,
        triggerAction: 'all',
        listClass: 'x-combo-list-small'
    });

    date_combo.on("select", function(combo, record, index) {
        this.store.load({params:{offset: 0, limit: 25, date: record.get("num")}});
    }, this);


    var status_tbar_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['PENDING', 'PENDING'],
                ['SHIPPED', 'SHIPPED'],
                ['CANCELLED', 'CANCELLED']
                ]
    });

    var status_combo_tbar= new Ext.form.ComboBox({
        store: status_tbar_st,
        width: 100,
        displayField:'txt',
        selectOnFocus:true,
        mode: 'local',
        typeAhead: false,
        triggerAction: 'all',
        listClass: 'x-combo-list-small'
        });

    status_combo_tbar.on("select", function(combo, record, index) {
        this.store.load({params:{offset: 0, limit: 25, status: record.get("num")}});
    }, this);

    var search_by_tbar_st = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : [['id', 'Order #'],
                ['customer', 'Customer']
                ]
    });

    var search_by_combo_tbar= new Ext.form.ComboBox({
        store: search_by_tbar_st,
        width: 100,
        valueField:'num',
        value: "id",
        displayField:'txt',
        selectOnFocus:true,
        mode: 'local',
        typeAhead: false,
        triggerAction: 'all',
        listClass: 'x-combo-list-small',
        pageX: 170,
        pageY: 105,
        editable: false
        });

    this.store.baseParams = { search_by: search_by };
    search_by_combo_tbar.on("select", function(combo, record, index) {
            search_by = record.get("num");
            this.store.baseParams = { search_by: search_by }
            //            this.store.load({params:{offset: 0, limit: 25, search_by: record.get("num")}});
        }, this);


    var lowdate = new Ext.form.DateField({});
    lowdate.on("change", function (field, newValue, oldValue) {
            start = newValue;
            //            this.store.baseParams = {}
        //            this.store.load({params:{offset: 0, limit: 25, lowdate: newValue}});
        }, this);

    var update = new Ext.form.DateField({});
    update.on("change", function (field, newValue, oldValue) {
            end = newValue;
            //            this.store.baseParams = { update: newValue }
            //            this.store.load({params:{offset: 0, limit: 25, update: newValue}});
        }, this);

    var user_search_field = new Ext.app.UserSearchField({
            store: this.store,
            width:150,
            pageX: 15,
            pageY: 105,
            emptyText: "           Search by"
        });


    this.store.on("beforeload", function(store, options) {
            if (store.baseParams.query) {
                this.store.baseParams = { query: store.baseParams.query, search_by: search_by };
            }
        }, this);

    var search_by_btn = new Ext.Button({ text: "Search", handler: searchByDate, scope: this});

    function searchByDate() {
        this.store.baseParams = {update: end.format('Ymd'), lowdate: start.format('Ymd')};
        this.store.load({params:{offset: 0, limit: 25}});
        //        this.store.baseParams = { search_by: search_by };
    }

    OrderGrid.superclass.constructor.call(this, {
            clicksToEdit: 1,
                autoScroll: true,
                /*                tbar: new Ext.Toolbar ({height:60, items: [
'Customer: ',
                       new Ext.app.SearchField({
                               store: this.store,
                                   width:150,
                                   }),' ','-',' ','Period:',
                       date_combo,' ','-',' ','Month:',month_combo,
                       ' ','-',' ','Status:',status_combo_tbar
                       , lowlabel, lowdate, update ]}),*/

                tbar: new Ext.Toolbar ({height:60,
                            items: [
                                    'Start: ',lowdate,
                                    ' ','-',' ',
                                    'End: ',update,
                                    ' ','-',' ',
                                    search_by_btn,
                                    ' ','-',' ',
                                    'Period: ',date_combo,
                                    user_search_field,
                                    ' ',
                                    search_by_combo_tbar
                                    ]}),

                viewConfig: {
                getRowClass: function(record, rowIndex, p, store){
                    if (record.get("current-status") == "SHIPPED") {
                        return "shipped";
                    }
                    if (record.get("current-status") == "CANCELLED") {
                        return "cancelled";
                    }
                }},


                bbar: new Ext.PagingToolbar({
                        pageSize: 25,
                            store: this.store,
                            paramNames: {start: 'offset', limit: 'limit'},
                            displayInfo: true,
                            displayMsg: 'Displaying products {0} - {1} of {2}',
                            emptyMsg: "No products to display",
                            items:['-', "Per page", perPage,'-']
                            })
                });

    this.on("afteredit", function(e) {
        if (e.field == "current-status") {
            if (e.value == "SHIPPED") {
                Ext.MessageBox.prompt('Tracking Code', 'Enter tracking code:', function (btn, text) {
                    if (btn == "ok" && text != "") {
                        var status_proxy = new Ext.data.HttpProxy({
                            url: '/orders/'+e.record.id+'/status/'+e.value,
                            method:'PUT'
                        });
                        status_proxy.load({i:111});

                        var track_code_proxy = new Ext.data.HttpProxy({
                            url: '/orders/'+e.record.id+'/tracking_code',
                            method:'POST'
                        });
                        track_code_proxy.load({value: text});
                    } else {
                        e.record.set("current_status", e.originalValue);
                        this.doLayout();
                    }
                }, this);
            } else if (e.value == "CANCELLED") {
                Ext.MessageBox.prompt('Order cancelled', 'Enter the reason to cancel this order:', function (btn, text) {
                    if (btn == "ok" && text != "") {
                        var status_proxy = new Ext.data.HttpProxy({
                            url: '/orders/'+e.record.id+'/status/'+e.value,
                            method:'PUT'
                        });
                        status_proxy.load({i:111});

                        var comments_proxy = new Ext.data.HttpProxy({
                            url: '/orders/'+e.record.id+'/comments',
                            method:'POST'
                        });
                        comments_proxy.load({value: text});
                    } else {
                        e.record.set("current_status", e.originalValue);
                        this.doLayout();
                    }
                }, this, 80);
            } else {
                var proxy = new Ext.data.HttpProxy({
                    url: '/orders/'+e.record.id+'/status/'+e.value,
                    method:'PUT'
                });
                proxy.load({i: 111});
            }
        }
    }, this);
};

Ext.extend(OrderGrid, Ext.grid.EditorGridPanel, {
});