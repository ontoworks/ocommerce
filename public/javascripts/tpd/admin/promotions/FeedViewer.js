/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

//FeedViewer = {};

Ext.onReady(function(){
    Ext.QuickTips.init();

    var product_id = "";
    var selected_kit = "";


    var kits_store = {};

    var feeds = new FeedPanel();
    var couponPanel = new CouponPanel();

	couponPanel.on("actioncomplete", function(form, action) {
		alert("here!");
	}, this);

    var viewport = new Ext.Panel({
    //    var viewport = new Ext.Viewport({
        el: "entry-div",
        layout:'border',
        title: "Admin Kits",
        items:[
            feeds,
            couponPanel
         ],
        defaults: { border: true, bodyBorder: true },
        width: 800,
        height: 600
    });

    viewport.render();
});