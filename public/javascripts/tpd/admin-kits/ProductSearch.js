

ProductSearch = function() {
    this.Product = Ext.data.Record.create([
        {name: 'name', type: 'string'},
        {name: 'model', type: 'string'}
    ]);

    this.search_store = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy({
              url: '/products.xml',
              method: 'GET'
        }),

        reader: new Ext.data.XmlReader({
              record: 'product',
              id: 'id'
           }, this.Product),

        sortInfo:{field:'name', direction:'DESC'}
    });

    this.search_store.on("load", searchLoad, this);

    function searchLoad(store, records, options) {
        if (store.getCount() > 0) {
//            this.preview.body.update('');
            var items = this.preview.topToolbar.items;
            items.get('add').enable();
            items.get('copy').enable();
        }
    }

    this.sm = new Ext.grid.CheckboxSelectionModel({singleSelect:true});

    this.cm = new Ext.grid.ColumnModel([
        this.sm,
        {
           id:'name',
           header: "Name",
           dataIndex: 'name',
           width: 400
        },{
           header: "Model",
           dataIndex: 'model',
           width: 100
        }
    ]);

//    this.preview = new Ext.grid.GridPanel({
      ProductSearch.superclass.constructor.call(this, {
        cm: this.cm,
        sm: this.sm,
        height: 300,
        id: 'preview',
        cls:'preview',
        autoScroll: true,
        viewConfig: {
            forceFit:true
        }
    });

}