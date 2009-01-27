ContentPanel = function(product_id, contentView) {
    this.contentView = new ContentView(product_id, contentView);

    ContentPanel.superclass.constructor.call(this, {
        id:'main-tabs',
        renderTo: contentView,
        border: 0,  
        layout: 'card',
        activeItem:0,
//        activeTab:0,
        margins:'0 5 5 0',
//        region: 'center',
//        resizeTabs:true,
//        tabWidth:150,
//        minTabWidth: 120,
        height: 500,
//        enableTabScroll: true,
//        plugins: new Ext.ux.TabCloseMenu(),
        items: [this.contentView]

    });
};

Ext.extend(ContentPanel, Ext.Panel, {
});