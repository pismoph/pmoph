// create namespace for plugins
Ext.namespace('Ext.ux.plugins');
Ext.ux.plugins.HelpText = {
    init: function(container){
        Ext.apply(container, {
            onRender: container.onRender.createSequence(function(ct, position){
                // if there is helpText create a div and display the text below the field
                if (typeof this.helpText == 'string') {
                    this.wrap = this.wrap || this.el.wrap();
                    this.wrap.createChild({
                            tag: 'div',
                            cls: typeof this.helpTextClass != 'undefined' ? this.helpTextClass : '',
                            style: typeof this.helpTextClass != 'undefined' ? 'clear: both;' : 'clear: both; font-size: 9px; color: #888888;',
                            html: this.helpText
                        });
                }
            }) // end of function onRender
        });
        
    } // end of function init
}
Ext.ux.plugins.HelpText = Ext.extend(Ext.ux.plugins.HelpText, Ext.util.Observable);
// end of file