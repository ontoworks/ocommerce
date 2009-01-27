/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

FeedViewer = {};

Ext.onReady(function(){
    Ext.QuickTips.init();

//    Ext.state.Manager.setProvider(new Ext.state.SessionProvider({state: Ext.appState}));

    var tpl = Ext.Template.from('preview-tpl', {
        compiled:true,
        getBody : function(v, all){
            return Ext.util.Format.stripScripts(v || all.description);
        }
    });
    FeedViewer.getTemplate = function(){
        return tpl;
    }

    var feeds = new FeedPanel();
    var mainPanel = new MainPanel();

    feeds.on('feedselect', function(feed){
        mainPanel.loadFeed(feed);
    });

    var viewport = new Ext.Panel({
        el: "entry-div",
        layout:'border',
        title: "Global Configuration",
        items:[
            new Ext.BoxComponent({ // raw element
                region:'north',
                el: 'header',
                height:4
            }),
            feeds,
            mainPanel
         ],
        defaults: { border: true },
        width: 800,
        height: 600 
    });

    viewport.render();

    // add some default feeds
    feeds.addFeed({
        view:'users',
        text: 'Users'
    }, false, true);

    feeds.addFeed({
        view:'shipping_modules',
        text: 'Shipping Modules'
    }, true);

    feeds.addFeed({
        view:'handling_fees',
        text: 'S&H-Packaging Fees'
    }, true);

    feeds.addFeed({
        view:'warranty',
        text: 'Warranties'
    }, true);

    feeds.addFeed({
        view:'payment',
        text: 'Payment Modules'
    }, true);

    feeds.addFeed({
        view:'taxes',
        text: 'Taxes'
    }, true);

    feeds.addFeed({
        view:'brands',
        text: 'Product Brands'
    }, true);
});

// This is a custom event handler passed to preview panels so link open in a new windw
FeedViewer.LinkInterceptor = {
    render: function(p){
        p.body.on({
            'mousedown': function(e, t){ // try to intercept the easy way
                t.target = '_blank';
            },
            'click': function(e, t){ // if they tab + enter a link, need to do it old fashioned way
                if(String(t.target).toLowerCase() != '_blank'){
                    e.stopEvent();
                    window.open(t.href);
                }
            },
            delegate:'a'
        });
    }
};