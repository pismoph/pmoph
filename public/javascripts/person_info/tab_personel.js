var tab_personel = new Ext.TabPanel({
    activeTab: 0
    ,title: "ข้าราชการ"
    ,tbar: [
        {
            text: "รายงาน ทะเบียนประวัติข้าราชการ"
            ,iconCls: "report"
            ,handler: function(){
                if (data_personel_id != ""){
                    var form = document.createElement("form");
                    form.setAttribute("method", "post");
                    form.setAttribute("action", pre_url + "/info_personal/report?format=pdf");
                    form.setAttribute("target", "_blank");
                    
                    var hiddenField = document.createElement("input");              
                    hiddenField.setAttribute("name", "id");
                    hiddenField.setAttribute("value", data_personel_id);
                    form.appendChild(hiddenField);									
                    document.body.appendChild(form);
                    form.submit();
                    document.body.removeChild(form);                     
                }
            }
        },"-"
    ]
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

var tab_personel_tmp = new Ext.Panel({
    title: 'ข้าราชการ'
    ,layout: "fit"
    ,items: [tab_personel]
});