

//SearchProduct = function() {
SearchProduct = function(viewer, config) {
    this.viewer = viewer;
    Ext.apply(this, config);

    this.Product = Ext.data.Record.create([
        {name: 'name', type: 'string'},
        {name: 'model', type: 'string'}
    ]);

    this.store = new Ext.data.Store({
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

    this.sm = new Ext.grid.CheckboxSelectionModel({singleSelect:true});

    this.columns = [
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
    ];

    this.tbar = [
        'Search for products: ',
        new Ext.app.SearchField({
            store: this.store,
            width:200
        })
    ];

//    this.preview = new Ext.grid.GridPanel({
    SearchProduct.superclass.constructor.call(this, {
        autoScroll: true
    });


};

Ext.extend(SearchProduct, Ext.grid.GridPanel, {
});