Ext.onReady(function(){
    Ext.QuickTips.init();

    // set up the Album tree
    var tree = new Ext.tree.TreePanel({
         // tree
         animate:true,
         enableDD:true,
         containerScroll: true,
         ddGroup: 'organizerDD',
         rootVisible:false,
         // layout
         region:'west',
         width:200,
         split:true,
         // panel
         title:'Kits',
         autoScroll:true,
         tbar: tb,
         margins: '5 0 5 5'
    });

    var root = new Ext.tree.TreeNode({
        text: 'Albums',
        allowDrag:false,
        allowDrop:false
    });
    tree.setRootNode(root);

    root.appendChild(
        new Ext.tree.TreeNode({text:'Platinum', cls:'platinum-node', allowDrag:false}),
        new Ext.tree.TreeNode({text:'Golden', cls:'golden-node', allowDrag:false}),
        new Ext.tree.TreeNode({text:'Silver', cls:'silver-node', allowDrag:false})
    );

    var view = new Ext.DataView({
        style:'overflow:auto',
        store: new Ext.data.JsonStore({
            url: '../view/get-images.php',
            autoLoad: true,
            root: 'images',
            id:'name',
            fields:[
                'price', 'image_url'
            ]
        }),
        tpl: new Ext.XTemplate(
            '<tpl for=".">',
            '<div class="thumb-wrap" id="{name}">',
            '<div class="thumb"><img src="../view/{url}" class="thumb-img"></div>',
            '<span>{shortName}</span></div>',
            '</tpl>'
        )
    });

});