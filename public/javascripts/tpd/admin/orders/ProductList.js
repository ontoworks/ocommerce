/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

ProductList = function(){
    this.grid = new FeedGrid(this, {
    });

    MainPanel.superclass.constructor.call(this, {
        id:'main-tabs',
        activeTab:0,
        region:'center',
        margins:'0 0 5 5',
        resizeTabs:true,
        tabWidth:200,
        minTabWidth: 120,
        enableTabScroll: true,
        items: {
            id:'main-view',
            layout:'border',
            title:'Products in this order',
            hideMode:'offsets',
            items:[
                this.grid
             ]
        }
    });
};

Ext.extend(MainPanel, Ext.TabPanel, {
    loadFeed : function(feed){
        this.grid.loadFeed(feed);
//        Ext.getCmp('main-view').setTitle(feed.text);
    }
});