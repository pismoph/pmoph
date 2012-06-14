//-------------------------------------
// Form Center
//-------------------------------------
var outPositionForm = new Ext.FormPanel({
    labelWidth: 100
    ,autoScroll: true
    ,url: pre_url + '/out_position/process_out_position'
    ,frame: true
    ,monitorValid: true
    ,bodyStyle: "padding:10px"
    ,region: "center"
    ,items: [
        {
            xtype: "panel"
            ,width: 1000
            ,layout: "form"
            ,labelAlign: "right"
            ,items: [
                new Ext.ux.form.PisComboBox({//การเคลื่อนไหว
                    fieldLabel: 'การเคลื่อนไหว'
                    ,hiddenName: 'cmd[updcode]'
                    ,id: 'cmd[updcode]'
                    ,width: 250
                    ,valueField: 'updcode'
                    ,displayField: 'updname'
                    ,urlStore: pre_url + '/code/cupdate'
                    ,fieldStore: ['updcode', 'updname']
                    ,anchor: "100%"
                    ,allowBlank: false
                })
                ,{
                    xtype: "compositefield"
                    ,fieldLabel: "คำสั่ง"
                    ,items: [
                        {
                            xtype: "textfield"
                            ,id: "cmd[refcmnd]"
                            ,width: 580
                            ,allowBlank: false
                        }
                        ,{
                            xtype: "displayfield"
                            ,value: "วันที่คำสั่งมีผลบังคับ"
                            ,style: "padding: 4px;text-align: right;padding-left: 10px"
                        }
                        ,{
                            xtype: "datefield"
                            ,id: "cmd[forcedate]"
                            ,width: 173
                            ,allowBlank: false
                            ,format: "d/m/Y"
                        }
                    ]
                }
                ,{
                    xtype: "compositefield"
                    ,fieldLabel: "เลขที่ตำแหน่ง"
                    ,anchor: "100%"
                    ,items: [
                        {
                            xtype: "numberfield"
                            ,id: "olded[posid]"
                            ,width: 100
                            ,enableKeyEvents: true
                            ,allowBlank: false
                            ,listeners: {
                                keydown : function( el,e ){
                                    Ext.getCmp("out_name").setValue("");
                                    if (e.keyCode == e.RETURN){
                                        loadMask.show();
                                        Ext.Ajax.request({
                                            url: pre_url + '/info_personal/search_posid'
                                            ,params: {
                                                posid: el.getValue()
                                            }
                                            ,success: function(response,opts){
                                                obj = Ext.util.JSON.decode(response.responseText);
                                                if (obj.success){
                                                    Ext.getCmp("olded[id]").setValue(obj.data[0].id);
                                                    Ext.getCmp("out_name").setValue(obj.data[0].name);
                                                    Ext.getCmp("olded[posid]").setValue(obj.data[0].posid);
                                                }
                                                else{
                                                    Ext.getCmp("olded[id]").setValue("");
                                                    Ext.getCmp("out_name").setValue("");
                                                    Ext.getCmp("olded[posid]").setValue("");
                                                    Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                }
                                                loadMask.hide();
                                            }
                                            ,failure: function(response,opts){
                                                Ext.Msg.alert("สถานะ",response.statusText);
                                                loadMask.hide();
                                            }
                                        });                                                                                           
                                    }        
                                }
                                ,blur: function(el){
                                    if (Ext.getCmp("out_name").getValue() == ""){
                                       Ext.getCmp("olded[id]").setValue("");
                                       Ext.getCmp("out_name").setValue("");
                                       Ext.getCmp("olded[posid]").setValue("");
                                    }
                                }
                            }
                        }
                        ,{
                            xtype: "button"
                            ,text: "..."
                            ,handler: function(){
                                personelNow(Ext.getCmp("olded[posid]"),Ext.getCmp("out_name"),Ext.getCmp("olded[id]"));
                            }
                        }
                        ,{
                            xtype: "displayfield"
                            ,value: "ชื่อ-นามสกุล"
                            ,style: "padding: 4px;text-align: right;padding-left: 10px"
                        }
                        ,{
                            xtype: "textfield"
                            ,id: "out_name"
                            ,readOnly: true
                            ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                        }
                        
                        ,{
                            xtype: "hidden"
                            ,id:  "olded[id]"
                        }
                    ]
                }
                ,{
                    xtype: "fieldset"
                    ,title: "ตำแหน่งที่แต่งตั้ง"
                    ,items: [
                        {
                            xtype: "numberfield"
                            ,id: "newed[posid]"
                            ,fieldLabel: "เลขที่ตำแหน่ง"
                        }
                        ,{
                            layout: "column"
                            ,items: [
                                {
                                    width: 320
                                    ,layout: "form"
                                    
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                            fieldLabel: "ตำแหน่งสายงาน"
                                            ,hiddenName: 'newed[poscode]'
                                            ,id: 'newed[poscode]'
                                            ,valueField: 'poscode'
                                            ,displayField: 'posname'
                                            ,urlStore: pre_url + '/code/cposition'
                                            ,fieldStore: ['poscode', 'posname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                            fieldLabel: "ตำแหน่งบริหาร"
                                            ,hiddenName: 'newed[excode]'
                                            ,id: 'newed[excode]'
                                            ,valueField: 'excode'
                                            ,displayField: 'exname'
                                            ,urlStore: pre_url + '/code/cexecutive'
                                            ,fieldStore: ['excode', 'exname']
                                            ,anchor: "95%"
                                        })                                        
                                    ]
                                }
                                ,{
                                    width: 320
                                    ,layout: "form"
                                    
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//ระดับ
                                            fieldLabel: "ระดับ"
                                            ,hiddenName: 'newed[c]'
                                            ,id: 'newed[c]'
                                            ,valueField: 'ccode'
                                            ,displayField: 'cname'
                                            ,urlStore: pre_url + '/code/cgrouplevel'
                                            ,fieldStore: ['ccode', 'cname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                            fieldLabel: "ความเชี่ยวชาญ"
                                            ,hiddenName: 'newed[epcode]'
                                            ,id: 'newed[epcode]'
                                            ,valueField: 'epcode'
                                            ,displayField: 'expert'
                                            ,urlStore: pre_url + '/code/cexpert'
                                            ,fieldStore: ['epcode', 'expert']
                                            ,anchor: "95%"
                                        })                                        
                                    ]
                                }
                                ,{
                                    width: 320
                                    ,layout: "form"
                                    
                                    ,items: [
                                        {
                                            xtype: "numberfield"
                                            ,id: "newed[salary]"
                                            ,fieldLabel: "เงินเดือน"
                                            ,anchor: "95%"
                                        }
                                        ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                            fieldLabel: "ว./ว.ช/ชช."
                                            ,hiddenName: 'newed[ptcode]'
                                            ,id: 'newed[ptcode]'
                                            ,valueField: 'ptcode'
                                            ,displayField: 'ptname'
                                            ,urlStore: pre_url + '/code/cpostype'
                                            ,fieldStore: ['ptcode', 'ptname']
                                            ,anchor: "95%"
                                        })                                        
                                    ]
                                }
                            ]
                        }
                        ,new Ext.ux.form.PisComboBox({//กระทรวง
                            fieldLabel: "กระทรวง"
                            ,hiddenName: 'newed[mincode]'
                            ,id: 'newed[mincode]'
                            ,valueField: 'mcode'
                            ,displayField: 'minname'
                            ,urlStore: pre_url + '/code/cministry'
                            ,fieldStore: ['mcode', 'minname']
                            ,anchor: "95%"                                                              
                        })
                        ,new Ext.ux.form.PisComboBox({//กรม
                            fieldLabel: "กรม"
                            ,hiddenName: 'newed[deptcode]'
                            ,id: 'newed[deptcode]'
                            ,valueField: 'deptcode'
                            ,displayField: 'deptname'
                            ,urlStore: pre_url + '/code/cdept'
                            ,fieldStore: ['deptcode', 'deptname']
                            ,anchor: "95%" 
                        })
                        ,new Ext.ux.form.PisComboBox({//กอง
                            hiddenName: 'newed[dcode]'
                            ,id: 'newed[dcode]'
                            ,fieldLabel: "กอง"
                            ,valueField: 'dcode'
                            ,displayField: 'division'
                            ,urlStore: pre_url + '/code/cdivision'
                            ,fieldStore: ['dcode', 'division']
                            ,anchor: "95%"
                        })
                        ,{
                            xtype: "compositefield"
                            ,fieldLabel: "หน่วยงาน"
                            ,anchor: "95%"
                            ,items: [
                                     {
                                              xtype: "numberfield"
                                              ,id: "newed[sdcode]"
                                              ,width: 80
                                              ,enableKeyEvents: true
                                              ,listeners: {
                                                       keydown : function( el,e ){
                                                                Ext.getCmp("subdept_show_right").setValue("");
                                                                if (e.keyCode == e.RETURN){
                                                                         loadMask.show();
                                                                         Ext.Ajax.request({
                                                                            url: pre_url + '/code/csubdept_search'
                                                                            ,params: {
                                                                               sdcode: el.getValue()
                                                                            }
                                                                            ,success: function(response,opts){
                                                                               obj = Ext.util.JSON.decode(response.responseText);
                                                                               if (obj.totalcount == 0){
                                                                                  Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                  Ext.getCmp("newed[sdcode]").setValue("");
                                                                                  Ext.getCmp("subdept_show_right").setValue("");
                                                                               }
                                                                               else{
                                                                                  Ext.getCmp("newed[sdcode]").setValue(obj.records[0].sdcode);
                                                                                  Ext.getCmp("subdept_show_right").setValue(obj.records[0].subdeptname);
                                                                               }
                                                                               
                                                                               loadMask.hide();
                                                                            }
                                                                            ,failure: function(response,opts){
                                                                               Ext.Msg.alert("สถานะ",response.statusText);
                                                                               loadMask.hide();
                                                                            }
                                                                         });                                                                                           
                                                                }        
                                                       }
                                                       ,blur: function(el){
                                                                if (Ext.getCmp("subdept_show_right").getValue() == ""){
                                                                         Ext.getCmp("newed[sdcode]").setValue("");
                                                                         Ext.getCmp("subdept_show_right").setValue("");    
                                                                }
                                                       }
                                                       
                                              }
                                        }
                                        ,{
                                                 xtype: "textfield"
                                                 ,id: "subdept_show_right"
                                                 ,readOnly: true
                                                 ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:220px;"
                                        }
                                        ,{
                                                 xtype: "button"
                                                 ,id: "sdcode_button"
                                                 ,text: "..."
                                                 ,handler: function(){
                                                          searchSubdept(Ext.getCmp("newed[sdcode]"),Ext.getCmp("subdept_show_right"));
                                                 }
                                        }
                                 ]
                        }
                        ,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                            fieldLabel: "ฝ่าย/กลุ่มงาน"
                            ,hiddenName: 'newed[seccode]'
                            ,id: 'newed[seccode]'
                            ,valueField: 'seccode'
                            ,displayField: 'secname'
                            ,urlStore: pre_url + '/code/csection'
                            ,fieldStore: ['seccode', 'secname']
                            ,anchor: "95%"                                                
                        })
                        ,new Ext.ux.form.PisComboBox({//งาน
                            fieldLabel: "งาน"
                            ,hiddenName: 'newed[jobcode]'
                            ,id: 'newed[jobcode]'
                            ,valueField: 'jobcode'
                            ,displayField: 'jobname'
                            ,urlStore: pre_url + '/code/cjob'
                            ,fieldStore: ['jobcode', 'jobname']
                            ,anchor: "95%"
                        }) 
                    ]
                }
                ,{
                    xtype: "textfield"
                    ,id: 'cmd[note]'
                    ,fieldLabel: "หมายเหตุ"
                    ,anchor: "95%"
                }
                ,{
                    layout: "column"
                    ,items: [
                        {
                            columsWidth: 1
                            ,layout: "form"
                            ,labelWidth: 190
                            ,items: [
                                {
                                    xtype: "xcheckbox"
                                    ,id:"flagupdate"
                                    ,submitOffValue:'0'
                                    ,submitOnValue:'1'
                                    ,fieldLabel: "<b>ตัดโอนตำแหน่งและอัตราเงินเดือน</b>"
                                }
                            ]
                        }
                    ]
                }
                

                
            ]
        }
    ]
    ,buttons:[
    { 
        text:'บันทึก'
        ,formBind: true 
        ,handler:function(){ 					
            outPositionForm.getForm().submit(
            { 
                method:'POST'
                ,waitTitle:'Saving Data'
                ,waitMsg:'Sending data...'
                ,success:function(){
                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย");
                    outPositionForm.getForm().reset();
                }
                ,failure:function(form, action){ 
                        if(action.failureType == 'server'){ 
                                obj = Ext.util.JSON.decode(action.response.responseText); 
                                Ext.Msg.alert('สถานะ', obj.msg); 
                        }
                        else{	 
                                Ext.Msg.alert('สถานะ', 'Authentication server is unreachable: ' + action.response.responseText); 
                        } 
                } 
            }); 
        } 
    },{
        text: "ยกเลิก"
        ,handler: function(){
            outPositionForm.getForm().reset();  
        }
    }
] 

});

//-------------------------------------
// Panel Main
//-------------------------------------
var outPositionPanel = new Ext.Panel({
    layout: "border"
    ,title: "คำสั่งย้ายออกนอกหน่วยงาน / ลาออก / เกษียณอายุ / ตาย"
    ,items: [
        outPositionForm 
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
        }
    }
});