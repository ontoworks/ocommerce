/*
 * Ontoworks
 * Copyright(c) 2008, Ontoworks, LLC.
 * licensing@ontoworks.com
 *
 * http://ontoworks.com/license
 */

ContentView = function(product_id, contentView){
    var ADD_NEW_CATEGORY_LINK_TEXT = "Add category";

    this.contentView = contentView;
    
    var category_id = 0;
    var Category = Ext.data.Record.create([
        {name: 'id', type: 'int'},
        {name: 'text', type: 'string'},
        {name: 'parent_id', type: 'int'}
    ]);
    
    var Product = Ext.data.Record.create([
        {name: 'height', type: 'float'},
        {name: 'weight', type: 'float'},
        {name: 'width', type: 'float'},
        {name: 'name', type: 'string'},
        {name: 'description', type: 'string'},
        {name: 'model', type: 'string'},
        {name: 'condition'},
        {name: 'status'},
        {name: 'is_hot', type: 'boolean'},
        {name: 'free_shipping', type: 'boolean'},
        {name: 'freight', type: 'boolean'},
        {name: 'pricegrabber', type: 'boolean'},
        {name: 'nextag', type: 'boolean'},
        {name: 'shopzilla', type: 'boolean'},
        {name: 'category', type: 'int'},
        {name: 'brand', type: 'string'},
        {name: 'length1', type: 'float'}
    ]);
    
    var StatusData = [
        ['Y',  'Active'],
        ['N',  'Inactive'],
        ['D',  'Draft']
    ];
    
    var brand_combo = new Ext.form.ComboBox({
        fieldLabel: "Brand",
        name: "brand",
        store: new Ext.data.SimpleStore({
            fields: ['id', 'name'],
            data : brands
        }),
        displayField:'name',
        valueField:'id',
        typeAhead: true,
        mode: 'local',
        triggerAction: 'all',
        selectOnFocus:true,
        forceSelection: true
    });
    
     var st_store = new Ext.data.SimpleStore({
         fields: ['num', 'txt'],
         data : StatusData
     });

     var st_combo = new Ext.form.ComboBox({
         fieldLabel: "Status",
         name: "status",
         store: st_store,
         displayField:'txt',
         valueField:'num',
         typeAhead: true,
         mode: 'local',
         triggerAction: 'all',
         selectOnFocus:true,
         forceSelection: true
     });

    ConditionData = [
        ['New',  'New'],
        ['Refurbished',  'Refurbished'],
        ['Generic',  'Generic']
    ];
    
    var cond_store = new Ext.data.SimpleStore({
        fields: ['num', 'txt'],
        data : ConditionData
    });

    var condition_combo = new Ext.form.ComboBox({
        fieldLabel: "Condition",
        name: "condition",
        store: cond_store,
        displayField:'txt',
        typeAhead: true,
        mode: 'local',
        triggerAction: 'all',
        selectOnFocus:true
    });
    
     var hot_checkbox = new Ext.form.Checkbox({
         fieldLabel: "Hot?",
         name: "hot"
     });
    
    hot_checkbox.on("check", function(c, checked) {
        proxy = new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/hot/'+checked,
            method: 'PUT'
        });
        proxy.load({i: '111'}, null, Ext.emptyFn);
     }, this);

     var freight_checkbox = new Ext.form.Checkbox({
         fieldLabel: "Freight?",
         name: "freight"
     });
    
    freight_checkbox.on("check", function(c, checked) {
        proxy = new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/freight/'+checked,
            method: 'PUT'
        });
        proxy.load({i: '111'}, null, Ext.emptyFn);
     }, this);
    
    var free_checkbox = new Ext.form.Checkbox({
        fieldLabel: "Free Shipping?",
        name: "free"
     });
    
    free_checkbox.on("check", function(c, checked) {
        proxy = new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/free_shipping/'+checked,
            method: 'PUT'
        });
        proxy.load({i: '111'}, null, Ext.emptyFn);
    }, this);
    
/*    function show_marketplaces_selections() {
	var marketplaces_list = ["pricegrabber", "shopzilla", "nextag"];
	for (var i=0; i<marketplaces_list.length; i++) {
	    new Ext.form.Checkbox({
		fieldLabel: "",
		name: "pricegrabber"
	    });
	}
    }*/

    // 
    var pricegrabber_check = new Ext.form.Checkbox({
        fieldLabel: "Pricegrabber",
        name: "pricegrabber"
    });
    pricegrabber_check.on("check", function(c, checked) {
        proxy = new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/subscriptions',
            method: 'POST'
        });
        proxy.load({service: 'pricegrabber', state: checked}, null, Ext.emptyFn);
    }, this);

    var nextag_check = new Ext.form.Checkbox({
        fieldLabel: "Nextag",
        name: "nextag"
    });
    nextag_check.on("check", function(c, checked) {
        proxy = new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/subscriptions',
            method: 'POST'
        });
        proxy.load({service: 'nextag', state: checked}, null, Ext.emptyFn);
    }, this);

    var shopzilla_check = new Ext.form.Checkbox({
        fieldLabel: "Shopzilla",
        name: "shopzilla"
    });
    shopzilla_check.on("check", function(c, checked) {
        proxy = new Ext.data.HttpProxy({
            url: '/products/'+product_id+'/subscriptions',
            method: 'POST'
        });
        proxy.load({service: 'shopzilla', state: checked}, null, Ext.emptyFn);
    }, this);


    //
    // PRODUCT DETAILS FORM
    //
    var info_reader = new Ext.data.XmlReader({
        record: 'product',
        id: 'id'
    }, Product);
    
    
    // Esto NO debe hacerse. Buscar la manera de sacar la categoria del
    // producto sin necesidad de hacer un nuevo request
    var info_st = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
            url: 'products/'+product_id+'.xml',
            method: 'GET'
        }),
        reader: info_reader,
        sortInfo:{field:'status', direction:'DESC'}
    });
    info_st.load();
    info_st.on('load', function(store, records, options) {
        category_id = records[0].data.category
        if (records[0].get("is_hot")) {
            hot_checkbox.setValue(records[0].get("is_hot"));
        }
        if (records[0].get("is_freight")) {
            freight_checkbox.setValue(records[0].get("is_freight"));
        }
        if (records[0].get("free_shipping")) {
            free_checkbox.setValue(records[0].get("free_shipping"));
        }

        if (records[0].get("pricegrabber")) {
            pricegrabber_check.setValue(records[0].get("pricegrabber"));
        }
        if (records[0].get("nextag")) {
            nextag_check.setValue(records[0].get("nextag"));
        }
        if (records[0].get("shopzilla")) {
            shopzilla_check.setValue(records[0].get("shopzilla"));
        }
    }, this);
    
    this.info_form = new Ext.FormPanel({
        hideBorders: true,
        labelWidth: 75,
        frame:true,
        standardSubmit: true,
        title: 'Product Details',
        bodyStyle:'background:white; padding:5px 5px 0;',
        width: 425,
        reader: info_reader,
        url: 'products'+'/'+product_id+'.xml',
        method: 'GET',
        items: [{
            border: false,
            xtype:'fieldset',
            title: 'Product Information',
            autoHeight:true,
            defaults: {width: 210},
            defaultType: 'textfield',
            items :[
		{
		    fieldLabel: 'Name',
		    name: 'name',
		    width: 300,
		    allowBlank:false
	    },{
		fieldLabel: 'Model',
		name: 'model'
	    }, 
		brand_combo,
		condition_combo,
		st_combo,
		hot_checkbox, 
		free_checkbox,
		freight_checkbox
	    ]
        },{
            border: false,
            xtype:'fieldset',
            title: 'Product Dimensions',
            autoHeight:true,
            defaults: {width: 150},
            defaultType: 'textfield',
            items :[{
                fieldLabel: 'Weight',
                name: 'weight'
            },{
                fieldLabel: 'Width',
                name: 'width'
            },{
                fieldLabel: 'Length',
                name: 'length1'
            },{
                fieldLabel: 'Height',
                name: 'height'
            },{
                name: 'id',
                inputType: 'hidden',
                value: product_id
            }
		   ]
        },{ 
            border: false,
            xtype:'fieldset',
            title: 'Publish to marketplace:',
            autoHeight:true,
	    items:[pricegrabber_check,nextag_check,shopzilla_check]
	}],
        buttons: [{
            text: 'Save',
            handler: function() {
                this.info_form.getForm().submit({url: '/products/save_product_info', waitMsg: 'Updating Info ...', method: "POST"});
            },
            scope: this
        }]
      });
    
    this.info_form.getForm().load();

    var PriceList = Ext.data.Record.create([
        {name: 'customer', type: 'float'},
        {name: 'business', type: 'float'},
        {name: 'wholesale', type: 'float'},
    ]);
    
    //
    // PRICES FORM
    //
    this.price_form = new Ext.FormPanel({
	labelWidth: 75,
	frame:true,
	title: 'Price Contexts',
	bodyStyle:'background:white; padding:5px 5px 0',
	width: 260,
	
	reader: new Ext.data.XmlReader({
            record: 'price'
	}, PriceList),
	url: 'products'+'/'+product_id+'/prices',
	method: 'GET',
	
	items: [{
            border: false,
            xtype:'fieldset',
            title: 'Price Contexts',
            autoHeight:true,
            defaults: {width: 100},
            width:220,
            defaultType: 'textfield',
            allowDomMove: true,
            style:'background:white',
            items :[
		{
                    fieldLabel: 'Customer',
                    name: 'customer'
		},{
                    fieldLabel: 'Business',
                    name: 'business'
		},{
                    fieldLabel: 'Wholesale',
                    name: 'wholesale'
		},{
                    name: 'id',
                    inputType: 'hidden',
                    value: product_id
                }
            ]
       }],
	buttons: [{
            text: 'Save',
            handler: function() {
                this.price_form.getForm().submit({url: '/products/save_prices_list', waitMsg: 'Updating Prices ...', method: "POST"});
            },
            scope: this
	}]
    });
    
    this.price_form.getForm().load();
    /////////////
    //////////////////////////////////////////////////////// TREE BEGINS /////////////////////////////////////////////
    /////////////
    function createCategory(text, parent_node) {
	// POST /categories (:category[text], :category[parent_id])
	var proxy = new Ext.data.HttpProxy({
	    url: '/categories.json',
	    method: 'POST',						
	});
	var reader = new Ext.data.JsonReader({
	    root: "rows",
	    id: "id"
	}, Category);
	    
	proxy.load({'category[text]':text, 'category[parent_id]':parent_node.id},
		   reader, 
		   // callback
		   // Add node for new category
		   function (r, arg, success) {
		       if (success) {
			   alert("Category '" + text + "' succesfully created");
			   var newNode = new Ext.tree.TreeNode({
			       text: text,
			       id: r.records[0].id
			   });
			   newNode.appendChild(addCategoryNode(newNode));
			   parent_node.appendChild(newNode);
		       }
		   },
		   // scope
		   this
		  );
	    
	proxy.on("loadexception", function(proxy, o, resp, error) {
	    alert(error);
	}, this);		
    }
    
    function addCategoryNode(parent_node) {
	var node = new Ext.tree.TreeNode({
	    text: ADD_NEW_CATEGORY_LINK_TEXT,
	    icon: ""
	});
	node.on("click", function(){
	    // TODO levantar ventana
	    var namePrompt = Ext.MessageBox.prompt('New Category', 'New Category Name:', function(btn, text){
		if (btn == "ok" && text != "") {
		    createCategory(text, parent_node);
		} else {
		    // If no text, do nothing
		}
		
	    }, this);
	}, this);
	return node;
    }
    
    this.tree = new Ext.tree.TreePanel({
        allowDomMove: false,
        height: 390,
        width: 260,
        autoScroll:true,
        title: "Choose categories",
        animate:true,
	//         containerScroll: true,
        selModel: new Ext.tree.DefaultSelectionModel(),
        loader: new Ext.tree.TreeLoader({
            dataUrl:'products/categories.json',
            requestMethod: 'GET'
        })
    });
    
    // set the root node
    var root = new Ext.tree.AsyncTreeNode({
        text: 'All products',
        draggable:false,
        id:'source'
    });

    this.tree.setRootNode(root);
    root.select();
    root.expand();
    root.on("load", function() {
	var selected_node = this.tree.getNodeById(category_id);
	this.tree.selectPath(selected_node.getPath());
    }, this);
    
    
    this.tree.on("expandnode", function(node) {
	if (!node.firstChild) {
	    node.appendChild(addCategoryNode(node));
	} else {
	    if (node.firstChild.text != ADD_NEW_CATEGORY_LINK_TEXT) { // This means if Add category does not exist already
		node.insertBefore(addCategoryNode(node), node.firstChild);
	    }
	}
    }, this);
    
    this.tree.on("click", categorySelections, this);

////////////////////// END OF TREE //////////////////////////

     this.image_upload = new Ext.FormPanel({
         width: 280,
         fileUpload: true,
         standardSubmit: true,
         frame: true,
         bodyStyle:'background:white; padding:5px 5px 0',
         items: [{
             border: false,
             xtype:'fieldset',
             title: 'Upload Image',
             autoHeight:true,
             defaults: {width: 100},
             width:220,
             defaultType: 'textfield',
             style:'background:white',
             items: [{
                 allowBlank: false,
                 hideLabel: true,
                 name: 'image',
                 inputType: 'file'
             },{
                 name: 'id',
                 inputType: 'hidden',
                 value: product_id
             }]
         }],
         buttons: [{
             text: 'Submit',
             handler: function() {
                 this.image_upload.getForm().submit({url: '/products/upload_image', waitMsg: 'Uploading Image ...'});
             },
             scope: this
         }]
     });

    this.image_panel = new Ext.Panel({
        bbar: new Ext.Toolbar({
        }),
        width: 280,
        bodyStyle:'background:white; padding:5px 5px 0;',
        title: "Product images",
        border: true,
        layout: 'fit',
        autoLoad: "products/image/"+product_id
    });
    
    this.image_upload.on("actioncomplete", function() {
        this.image_panel.getUpdater().update({url: "products/image/"+product_id});
     }, this);
    
    function categorySelections(node, e) {
	if (node.text != ADD_NEW_CATEGORY_LINK_TEXT) {
	    category_id = node.id;
    	    this.tree.getSelectionModel().select(node, null, true);
            var proxy = new Ext.data.HttpProxy({
            	url: '/products/'+product_id+'/category/'+category_id,
	        method: 'POST'
            });
	    proxy.load({i:111}, null, Ext.emptyFn);
	}
    }
    
    function selectionChange(sm, nodes) {
        alert(this.tree.getSelectionModel.getSelectedNodes());
    };
    
    ContentView.superclass.constructor.call(this, {
        bodyBorder: false,
        border: false,
        renderTo: this.contentView,
        layout: 'table',
        defaults: {
            border: false,
             bodyStyle: 'padding:6px'
         },
	
        viewConfig: {
             forceFit:true
         },
	
        layoutConfig: {
             columns: 3
         },
         items: [{
             rowspan: 2,
             items: [this.image_panel, this.image_upload]
         },{
             items: this.info_form,
             rowspan: 2
         },{
	     height: 400,
             items: this.tree
         },{
             items: this.price_form
         }]
    });
};

Ext.extend(ContentView, Ext.Panel, {
});
