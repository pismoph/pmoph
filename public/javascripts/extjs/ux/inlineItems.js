// create namespace for plugins
Ext.namespace('Ext.ux.plugins');
Ext.ux.plugins.InlineItems = {
    init: function(container){
        Ext.apply(container, {
            onRender: container.onRender.createSequence(function(ct, position){
                // create the appended fields
                var ac = this.inlineItems || [];
                ac = Ext.isArray(ac) ? ac : [ac];
				
				
                if (ac.length > 0) {
                    var form = this.getForm();
                    
                    // create a wrap for all the fields including the one created above
                    this.wrap = this.el.wrap({
                        tag: 'div'
                    });
                    // also, wrap the field create above with the same div as the appending fields
                    this.el.wrap({
                        tag: 'div',
                        cls: 'x-form-append',
                        style: 'float: left; padding-right: 3px;'
                    });
                    for (var i = 0, len = ac.length; i < len; i++) {
                        // if the append field has append fields, delete this
                        delete ac[i].inlineItems;
                        // create a div wrapper with the new field within it.
                        var cell = this.wrap.createChild({
                            tag: 'div',
                            cls: 'x-form-append',
                            style: 'position: relative; float: left; padding-right: 3px;'
                        });
                        var field = new Ext.ComponentMgr.create(ac[i], 'button');
                        // render the field
                        field.render(cell);
                        cell.createChild({
                            tag: 'div',
                            cls: typeof ac[i].inlineItemLabelClass != 'undefined' ? ac[i].inlineItemLabelClass : '',
                            style: typeof ac[i].inlineItemLabelClass != 'undefined' ? 'clear: both;' : 'clear: both; font-size: 9px; color: #888888;',
                            html: ac[i].inlineItemLabel
                        });
                        
                        if (form && field.isFormField) {
                            form.items.add(field);
                        }
                    }
                };
				
				//Add the inline label if it's available
				if (typeof this.inlineItemLabel == 'string') {
					var wrpr = this.wrap = this.el.wrap({
						tag: 'div'
					});
					wrpr.createChild({
                            tag: 'div',
                            cls: typeof this.inlineItemLabelClass != 'undefined' ? this.inlineItemLabelClass : '',
                            style: typeof this.inlineItemLabelClass != 'undefined' ? 'clear: both;' : 'clear: both; font-size: 9px; color: #888888;',
                            html: this.inlineItemLabel
                        });
				};
                
            }),
            getForm: function(){
                var form;
                this.ownerCt.bubble(function(container){
                    if (container.form) {
                        form = container.form;
                        return false;
                    }
                }, this);
                
                return form;
            } // end of function onRender
        });
        
    } // end of function init
}
Ext.ux.plugins.InlineItems = Ext.extend(Ext.ux.plugins.InlineItems, Ext.util.Observable);
// end of file
