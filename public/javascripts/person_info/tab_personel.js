var tab_personel = new Ext.TabPanel({
    activeTab: 0
    ,items: [
        {
            title: 'ข้อมูลตำแหน่ง(จ.18)'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "j18";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/j18.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'ปฏิบัติราชการปัจจุบัน'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "perform_person_now";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/perform_now.js',"initInfoDetail");
                }
            }
        }
        ,{
            title: 'ประวัติการรับราชการ'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pisposhis";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/position_hist.js',"initInfoDetail");
                }
            }
        }
        ,{
            title: 'ข้อมูลส่วนตัว'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_personal";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/personal.js',"initInfoDetail");
                }
            }
        }
        ,{
            title: 'การศึกษา'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_education";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/education.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'การลา'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_absent";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/absent.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'การประชุม/อบรม'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_trainning";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/trainning.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'ประวัติเครื่อราชย์'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_insig";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/insig.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'โทษทางวินัย'
            ,layout: "card"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_punish";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/punish.js',"initInfoDetail");	
                }
            }
        }
    ]
    ,listeners: {
        afterrender: function(el){
            loadMask.show();
            cur_ref = "j18";
            Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info/j18.js',"initInfoDetail");	
        }
        ,beforetabchange: function( tp, newTab, currentTab ) {
            if (typeof currentTab != "undefined"){
                currentTab.removeAll();
                currentTab.setTitle(currentTab.initialConfig.title);
            }
            else{
                newTab.removeAll();
                newTab.setTitle(newTab.initialConfig.title);
            }
        }
    }
});