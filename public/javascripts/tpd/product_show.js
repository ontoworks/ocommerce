//Ext.onReady(function(){

//    Ext.QuickTips.init();

    var bd = Ext.getBody();

    bd.createChild({tag: 'h2', html: 'Form 2 - Adding fieldsets'});

    var fsf = new Ext.FormPanel({
        labelWidth: 75, // label settings here cascade unless overridden
        url:'save-form.php',
        frame:true,
        title: 'Simple Form with FieldSets',
        bodyStyle:'padding:5px 5px 0',
        width: 350,

        items: [{
            xtype:'fieldset',
            checkboxToggle:true,
            title: 'User Information',
            autoHeight:true,
            defaults: {width: 210},
            defaultType: 'textfield',
            collapsed: true,
            items :[{
                    fieldLabel: 'First Name',
                    name: 'first',
                    allowBlank:false
                },{
                    fieldLabel: 'Last Name',
                    name: 'last'
                },{
                    fieldLabel: 'Company',
                    name: 'company'
                }, {
                    fieldLabel: 'Email',
                    name: 'email',
                    vtype:'email'
                }
            ]
        },{
            xtype:'fieldset',
            title: 'Phone Number',
            collapsible: true,
            autoHeight:true,
            defaults: {width: 210},
            defaultType: 'textfield',
            items :[{
                    fieldLabel: 'Home',
                    name: 'home',
                    value: '(888) 555-1212'
                },{
                    fieldLabel: 'Business',
                    name: 'business'
                },{
                    fieldLabel: 'Mobile',
                    name: 'mobile'
                },{
                    fieldLabel: 'Fax',
                    name: 'fax'
                }
            ]
        }],

        buttons: [{
            text: 'Save'
        },{
            text: 'Cancel'
        }]
    });

    alert("Here???");
    fsfo.render();
//});