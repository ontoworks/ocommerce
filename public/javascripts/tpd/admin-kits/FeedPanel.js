/*
 * Ext JS Library 2.0.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */

FeedPanel = function() {
	FeedPanel.superclass.constructor.call(this, {
		id:'feed-tree',
		region:'west',
		title:'Promotions',
		split:true,
		width: 180,
		minSize: 180,
		maxSize: 180,
		margins:'5 0 5 5',
        cmargins:'5 5 5 5',
        rootVisible:false,
        autoScroll:true,
        root: new Ext.tree.TreeNode('Feed Viewer'),
        collapseFirst:false
    });

    this.feeds = this.root.appendChild(
        new Ext.tree.TreeNode({
            text:'My Promotions',
            cls:'feeds-node',
            expanded:true
        })
    );

    this.getSelectionModel().on({
        'beforeselect' : function(sm, node){
             return node.isLeaf();
        },
        'selectionchange' : function(sm, node){
            if(node){
                this.fireEvent('feedselect', node.attributes);
            }
//            this.getTopToolbar().items.get('delete').setDisabled(!node);
        },
        scope:this
    });

    this.addEvents({feedselect:true});
};

Ext.extend(FeedPanel, Ext.tree.TreePanel, {
    addFeed : function(attrs, inactive, preventAnim){
        var exists = this.getNodeById(attrs.type);
        if(exists){
            if(!inactive){
                exists.select();
                exists.ui.highlight();
            }
            return;
        }
        Ext.apply(attrs, {
//            iconCls: 'feed-icon',
            leaf:true,
            cls:'feed',
            id: attrs.type
        });
        var node = new Ext.tree.TreeNode(attrs);
        this.feeds.appendChild(node);
        if(!inactive){
            if(!preventAnim){
                Ext.fly(node.ui.elNode).slideIn('l', {
                    callback: node.select, scope: node, duration: .4
                });
            }else{
                node.select();
            }
        }
        return node;
    }
});