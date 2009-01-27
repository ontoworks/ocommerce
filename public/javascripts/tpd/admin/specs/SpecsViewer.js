/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

//Ext.onReady(function(){

SpecsViewer = function(product_id) {
Ext.QuickTips.init();

        //    Ext.state.Manager.setProvider(
        //            new Ext.state.SessionProvider({state: Ext.appState}));

//    var button = Ext.get('show-btn');

//    button.on('click', function(){


    var ProductDesc = Ext.data.Record.create([
        {name: 'product_id'},
        {name: 'specs'},
        {name: 'features'},
        {name: 'includes'},
        {name: 'warranty'},
        {name: 'overview'},
        {name: 'features_desc'},
        {name: 'main_info'}
    ]);


    var specs = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Specs',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'specs',
            fieldLabel:'Specs',
            height:300,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                specs.getForm().submit({url: '/products/'+product_id+'/desc/specs', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });
    var features = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Features',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'features',
            fieldLabel:'Features',
            height:200,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                features.getForm().submit({url: '/products/'+product_id+'/desc/features', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });
    var features_desc = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Features Desc',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'features_desc',
            fieldLabel:'Features Desc',
            height:200,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                features_desc.getForm().submit({url: '/products/'+product_id+'/desc/features_desc', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });
    var main_info = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Main Info',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'main_info',
            fieldLabel:'Main Info',
            height:200,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                main_info.getForm().submit({url: '/products/'+product_id+'/desc/main_info', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });
    var includes = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Includes',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'includes',
            fieldLabel:'Includes',
            height:200,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                includes.getForm().submit({url: '/products/'+product_id+'/desc/includes', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });
    var warranty = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Warranty',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'warranty',
            fieldLabel:'Warranty',
            height:200,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                warranty.getForm().submit({url: '/products/'+product_id+'/desc/warranty', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });
    var overview = new Ext.FormPanel({
        labelAlign: 'top',
        frame:true,
        title: 'Overview',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        items: {
            xtype:'htmleditor',
            name: 'value',
            id:'overview',
            fieldLabel:'Overview',
            height:200,
            anchor:'98%'
        },

        buttons: [{
            text: 'Save',
            handler: function() {
                overview.getForm().submit({url: '/products/'+product_id+'/desc/overview', waitMsg: 'Updating Info ...', method: "PUT"});
            },
            scope: this
        }]
    });

    var store = new Ext.data.Store({
        reader: new Ext.data.XmlReader({ record: 'product_description' }, ProductDesc),
        proxy: new Ext.data.HttpProxy({
                url:'products/'+product_id+'/desc',
                method: 'GET'
            })
    });


    store.on("load", function(store, records, options) {
        var desc = records[0];
        var warranty_box = warranty.findById("warranty");
        warranty_box.setValue(desc.get("warranty"));
        var specs_box = specs.findById("specs");
        specs_box.setValue(desc.get("specs"));
        var main_info_box = main_info.findById("main_info");
        main_info_box.setValue(desc.get("main_info"));
        var features_box = features.findById("features");
        features_box.setValue(desc.get("features"));
        var features_desc_box = features_desc.findById("features_desc");
        features_desc_box.setValue(desc.get("features_desc"));
        var includes_box = includes.findById("includes");
        includes_box.setValue(desc.get("includes"));
        var overview_box = overview.findById("overview");
        overview_box.setValue(desc.get("overview"));
    }, this);

    store.load();

    // tabs for the center
    var tabs = new Ext.TabPanel({
        region: 'center',
        margins:'3 3 3 0',
        activeTab: 0,
        defaults:{autoScroll:true},
        //            hideMode: 'offsets',
        items:[
            main_info,specs,features,includes,
            warranty,overview,features_desc
               ]
        });


    //    var win = new Ext.Window({
    SpecsViewer.superclass.constructor.call(this, {
        title: 'Layout Window',
        closable:true,
        width:600,
        height:500,
        border:false,
        hideMode: 'offsets',
        plain:true,
        //            layout: 'border',
        layout: 'fit',

        items: tabs
        });

    //    win.show(this);
//        });
// });
};

Ext.extend(SpecsViewer, Ext.Window, {
    });

