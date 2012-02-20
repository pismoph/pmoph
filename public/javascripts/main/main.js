Ext.onReady(function(){
    var mainCenter = new Ext.Panel({
        region: 'center'
        ,id: "mainCenter"
        ,layout: "card"
        ,layoutConfig: {
            deferredRender: true
        }
        ,items: []
    });
    
    new Ext.Viewport({
            layout: 'border'
            ,items: [
                mainMenu
                ,mainCenter
            ]
    });   
    
    setTimeout(function(){
        Ext.get('loading').remove();
        Ext.get('loading-mask').fadeOut({remove:true});
    }, 250);    
});