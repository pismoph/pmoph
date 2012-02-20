Ext.ns('Ext.ux.form');
Ext.ux.form.PisComboBox = Ext.extend(Ext.form.ComboBox, {
    fieldStore: []
    ,rootStore: 'records'
    ,totalStore: 'totalcount'
    ,urlStore: ''
    ,initComponent: function(){
        Ext.apply(this, {    
            editable: true
            ,pageSize: 10
            ,minChars: 1
            ,store: new Ext.data.Store({
                reader: new Ext.data.JsonReader({
                    fields: this.fieldStore
                    ,root: this.rootStore                        
                    ,totalProperty: this.totalStore
                })
                ,url: this.urlStore
                ,listeners: {
                    load: function( store, records,options ) {
                        delete(store.baseParams["query"]);
                        if (store.lastOptions && store.lastOptions.params) {
                                delete(store.lastOptions.params["query"]);
                        }
                    }
                }
            })
            ,triggerAction: 'all'
            ,emptyText: 'Select ...'
            ,autoSelect: false
            ,listeners: {
                blur: function(el){
                    if (el.getValue() == el.getRawValue()){
                        el.clearValue();    
                    }
                }
                ,beforequery: function(qe){
                    delete qe.combo.lastQuery;
                } 
            }
        });
        Ext.ux.form.PisComboBox.superclass.initComponent.apply(this, arguments);
    }

});
Ext.reg('piscombobox', Ext.ux.form.PisComboBox);