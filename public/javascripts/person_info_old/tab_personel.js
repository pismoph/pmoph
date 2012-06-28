var tab_personel = new Ext.TabPanel({
    //activeTab: 0
    items: [
        {
            title: 'ปฏิบัติราชการครั้งสุดท้าย'
            ,layout: "card"
            ,id: "menu_perform_now"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "perform_person_now";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/perform_now.js',"initInfoDetail");
                }
            }
        }
        ,{
            title: 'ประวัติการรับราชการ'
            ,layout: "card"
            ,id: "menu_pisposhis"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pisposhis";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/position_hist.js',"initInfoDetail");
                }
            }
        }
        ,{
            title: 'ข้อมูลส่วนตัว'
            ,layout: "card"
            ,id: "menu_pispersonel"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_personal";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/personal.js',"initInfoDetail");
                }
            }
        }
        ,{
            title: 'การศึกษา'
            ,layout: "card"
            ,id: "menu_piseducation"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_education";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/education.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'การลา'
            ,layout: "card"
            ,id: "menu_pisabsent"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_absent";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/absent.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'การประชุม/อบรม'
            ,layout: "card"
            ,id: "menu_pistrain"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_trainning";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/trainning.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'ประวัติเครื่อราชย์'
            ,layout: "card"
            ,id: "menu_pisinsig"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_insig";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/insig.js',"initInfoDetail");	
                }
            }
        }
        ,{
            title: 'โทษทางวินัย'
            ,layout: "card"
            ,id: "menu_pispunish"
            ,listeners: {
                activate: function(el){
                    loadMask.show();
                    cur_ref = "data_pis_punish";
                    Ext.ux.OnDemandLoad.load(pre_url + '/javascripts/person_info_old/punish.js',"initInfoDetail");	
                }
            }
        }
    ]
    ,listeners: {
        afterrender: function(el){
            if(menu_perform_now == '0') tab_personel.hideTabStripItem("menu_perform_now");
            if(menu_pisposhis == '0') tab_personel.hideTabStripItem("menu_pisposhis");
            if(menu_pispersonel == '0') tab_personel.hideTabStripItem("menu_pispersonel");
            if(menu_piseducation == '0') tab_personel.hideTabStripItem("menu_piseducation");
            if(menu_pisabsent == '0') tab_personel.hideTabStripItem("menu_pisabsent");
            if(menu_pistrain == '0') tab_personel.hideTabStripItem("menu_pistrain");
            if(menu_pisinsig == '0') tab_personel.hideTabStripItem("menu_pisinsig");
            if(menu_pispunish == '0') tab_personel.hideTabStripItem("menu_pispunish");
            loadMask.hide();
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

var tab_personel_tmp = new Ext.Panel({
    title: 'อดีตราชการ'
    ,layout: "fit"
    ,items: [tab_personel]
});