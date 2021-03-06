work_place = {
         mcode: "group_user[mcode]"
         ,deptcode: "group_user[deptcode]"
         ,dcode: "group_user[dcode]"
         ,sdcode: "group_user[sdcode]"
         ,sdcode_show: "user_subdept_show"
         ,sdcode_button: "user_subdept_button"
         ,seccode: ""
         ,jobcode: ""
}

var userGroupFields = [
    {name: "id", type: "int"}
    ,{name: "name",type: "string"}
    ,{name: "menu_code",type: "string"}
    ,{name: "menu_manage_user",type: "string"}
    ,{name: "menu_personal_info",type: "string"}
    ,{name: "menu_report",type: "string"}
    ,{name: "menu_command",type: "string"}
    ,{name: "menu_search",type: "string"}
    ,{name: "admin",type: "string"}
    ,{name: "mcode",type: "string"}
    ,{name: "deptcode",type: "string"}
    ,{name: "dcode",type: "string"}
    ,{name: "sdcode",type: "string"}
    ,{name: "seccode",type: "string"}
    ,{name: "jobcode",type: "string"}
    ,{name: "work_place_name",type: "string"}
    ,{name: "user_subdept_show",type: "string"}
    ,{name: "type_group",type: "string"}
    ,{name: "provcode",type: "string"}
    ,{name: "menu_pisj18",type: "string"}
    ,{name: "menu_perform_now",type: "string"}
    ,{name: "menu_pisposhis",type: "string"}
    ,{name: "menu_pispersonel",type: "string"}
    ,{name: "menu_piseducation",type: "string"}
    ,{name: "menu_pisabsent",type: "string"}
    ,{name: "menu_pistrain",type: "string"}
    ,{name: "menu_pisinsig",type: "string"}
    ,{name: "menu_pispunish",type: "string"}
]; 

var userGroupCols = [
        {
                header: "#"
                ,width: 80
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }		
        ,{header: "กลุ่มผู้ใช้งาน",width: 150, sortable: false, dataIndex: 'name'}
        ,{header: "หน่วยงาน",width: 350, sortable: false, dataIndex: 'work_place_name'}
];

var userGroupGridStore = new Ext.data.JsonStore({
        url: pre_url + "/manage_user/read"
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: userGroupFields
        ,idProperty: 'id'
});

var userGroupGrid = new Ext.grid.GridPanel({
        title: "กลุ่มผู้ใช้งาน"
        ,region: 'north'
        ,height: 200
        ,split: true
        ,store: userGroupGridStore
        ,columns: userGroupCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
        ,bbar: new Ext.PagingToolbar({
            pageSize: 20
            ,autoWidth: true
            ,store: userGroupGridStore
            ,displayInfo: true
            ,displayMsg: 'Displaying {0} - {1} of {2}'
            ,emptyMsg: "Not found"
        })
        ,tbar: [
            {
                text: "เพิ่มกลุ่มผู้ใช้งาน(รพศ,รพท)"
                ,iconCls: "table-add"
                ,hidden: (type_group_user == "1")? false : true
                ,handler: function(){
                     if(!form){
                             var form = new Ext.FormPanel({ 
                                     labelWidth: 80
                                     ,autoScroll: true
                                     ,url: pre_url + '/manage_user/create'
                                     ,frame: true
                                     ,monitorValid: true
                                     ,bodyStyle: "padding:10px"
                                     ,items:[
                                        {
                                            xtype: "textfield"
                                            ,fieldLabel: "ชื่อกลุ่มผู้ใช้งาน"
                                            ,id: "group_user[name]"
                                            ,anchor: "95%"
                                            ,allowBlank: false
                                        }
                                        ,new Ext.ux.form.PisComboBox({//กระทรวง
                                            fieldLabel: "กระทรวง"
                                            ,hiddenName: 'group_user[mcode]'
                                            ,id: 'group_user[mcode]'
                                            ,valueField: 'mcode'
                                            ,displayField: 'minname'
                                            ,urlStore: pre_url + '/code/cministry'
                                            ,fieldStore: ['mcode', 'minname']
                                            ,anchor: "95%"                                                               
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กรม
                                            fieldLabel: "กรม"
                                            ,hiddenName: 'group_user[deptcode]'
                                            ,id: 'group_user[deptcode]'
                                            ,valueField: 'deptcode'
                                            ,displayField: 'deptname'
                                            ,urlStore: pre_url + '/code/cdept'
                                            ,fieldStore: ['deptcode', 'deptname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กอง
                                            fieldLabel: "กอง"
                                            ,hiddenName: 'group_user[dcode]'
                                            ,id: 'group_user[dcode]'
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
                                                 ,anchor: "100%"
                                                 ,items: [
                                                          {
                                                                   xtype: "numberfield"
                                                                   ,id: "group_user[sdcode]"
                                                                   ,width: 80
                                                                   ,enableKeyEvents: true
                                                                   ,allowBlank: false
                                                                   ,listeners: {
                                                                            keyup: function( el,e ){
                                                                                Ext.getCmp("user_subdept_show").setValue("");
                                                                            }
                                                                            ,specialkey : function( el,e ){
                                                                                     
                                                                                     if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
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
                                                                                                       Ext.getCmp("group_user[sdcode]").setValue("");
                                                                                                       Ext.getCmp("user_subdept_show").setValue("");
                                                                                                    }
                                                                                                    else{
                                                                                                       Ext.getCmp("group_user[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                       Ext.getCmp("user_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                                                     if (Ext.getCmp("user_subdept_show").getValue() == ""){
                                                                                              Ext.getCmp("group_user[sdcode]").setValue("");
                                                                                              Ext.getCmp("user_subdept_show").setValue("");    
                                                                                     }
                                                                            }
                                                                            
                                                                   }
                                                          }
                                                          ,{
                                                                   xtype: "textarea"
                                                                   ,id: "user_subdept_show"
                                                                   ,readOnly: true
                                                                   ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                                                   ,width: 240
                                                                   ,height: 50
                                                          }
                                                          ,{
                                                                   xtype: "button"
                                                                   ,id: "user_subdept_button"
                                                                   ,text: ")..."
                                                                   ,handler: function(){
                                                                            searchSubdept(Ext.getCmp("group_user[sdcode]"),Ext.getCmp("user_subdept_show"));
                                                                   }
                                                          }
                                                 ]
                                        }
                                        /*,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                            fieldLabel: "ฝ่าย/กลุ่มงาน"
                                            ,hiddenName: 'group_user[seccode]'
                                            ,id: 'group_user[seccode]'
                                            ,valueField: 'seccode'
                                            ,displayField: 'secname'
                                            ,urlStore: pre_url + '/code/csection'
                                            ,fieldStore: ['seccode', 'secname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//งาน
                                            fieldLabel: "งาน"
                                            ,hiddenName: 'group_user[jobcode]'
                                            ,id: 'group_user[jobcode]'
                                            ,valueField: 'jobcode'
                                            ,displayField: 'jobname'
                                            ,urlStore: pre_url + '/code/cjob'
                                            ,fieldStore: ['jobcode', 'jobname']
                                            ,anchor: "95%"
                                        })*/
                                        ,{
                                            xtype: "checkboxgroup"
                                            ,fieldLabel: "สมารถใช้งาน"
                                            ,columns: 3
                                            ,items: [
                                                { xtype: "xcheckbox" ,boxLabel: "รหัสข้อมูล",id: "group_user[menu_code]",submitOffValue:'0',submitOnValue:'1' ,hidden: (group_user_admin == '1')? false:true}
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ผู้ใช้งาน",id: "group_user[menu_manage_user]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "รายงาน",id: "group_user[menu_report]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "บันทึกคำสั่ง",id: "group_user[menu_command]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "สอบถามข้อมูล",id: "group_user[menu_search]",submitOffValue:'0',submitOnValue:'1' }                                               
                                            ]
                                        }
                                        ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลบุคคล",id: "group_user[menu_personal_info]",submitOffValue:'0',submitOnValue:'1'
                                            ,listeners: {
                                                check: function(el,check){
                                                    if (check){
                                                        Ext.getCmp("menu_detail_info").enable();
                                                    }else{
                                                        Ext.getCmp("menu_detail_info").setValue(['0','0','0','0','0','0','0','0','0']);
                                                        Ext.getCmp("menu_detail_info").disable();
                                                    }
                                                }
                                            }
                                        }
                                        ,{
                                            xtype: "checkboxgroup"
                                            ,hideLabel: true
                                            ,columns: 2
                                            ,id: "menu_detail_info"
                                            ,disabled: true
                                            ,style: "margin-left:100px"
                                            ,items: [
                                                { xtype: "xcheckbox" ,boxLabel: "ข้อมูลตำแหน่ง(จ.18)",id: "group_user[menu_pisj18]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ปฏิบัติราชการปัจจุบัน",id: "group_user[menu_perform_now]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติการรับราชการ",id: "group_user[menu_pisposhis]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลส่วนตัว",id: "group_user[menu_pispersonel]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "การศึกษา",id: "group_user[menu_piseducation]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "การลา",id: "group_user[menu_pisabsent]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "การประชุม/อบรม",id: "group_user[menu_pistrain]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติเครื่อราชย์",id: "group_user[menu_pisinsig]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "โทษทางวินัย",id: "group_user[menu_pispunish]",submitOffValue:'0',submitOnValue:'1' }
                                            ]
                                        }
                                        ,{ fieldLabel: "ผู้ดูแลระบบ",xtype: "xcheckbox" ,boxLabel: "ใช่/ไม่ใช่",id: "group_user[admin]",submitOffValue:'0',submitOnValue:'1',hidden: (group_user_admin == '1')? false:true }
                                        ,{
                                             xtype: "hidden"
                                             ,id: "group_user[type_group]"
                                             ,value: "1"
                                        }
                                    ]
                                    ,buttons:[
                                             { 
                                                     text:'บันทึก'
                                                     ,formBind: true 
                                                     ,handler:function(){
                                                               if (Ext.getCmp("group_user[menu_command]").getValue() == true && Ext.getCmp("group_user[sdcode]").getValue() == ""){
                                                                        Ext.Msg.alert("คำเตือน","ถ้าเลือก  สามารถใช้งาน \"บันทึกคำสั่ง\" ต้องกำหนด หน่วยงานด้วย")
                                                                        return false;
                                                               }
                                                             form.getForm().submit(
                                                             { 
                                                                     method:'POST'
                                                                     ,waitTitle:'Saving Data'
                                                                     ,waitMsg:'Sending data...'
                                                                     ,success:function(){		
                                                                             Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                                             if (btn == 'ok')
                                                                                             {
                                                                                                        userGroupGridStore.reload();
                                                                                                        win.close();											
                                                                                             }	
                                                                                     }
                                                                             );                                          
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
                                                     ,handler: function	(){
                                                             win.close();
                                                     }
                                             }
                                     ] 
                             });
                     }//end if form
                     if(!win){
                             var win = new Ext.Window({
                                     title: 'เพิ่มกลุ่มผู้ใช้งาน(รพศ,รพท)'
                                     ,width: 500
                                     ,height: 500
                                     ,closable: true
                                     ,resizable: false
                                     ,plain: true
                                     ,border: false
                                     ,draggable: true 
                                     ,modal: true
                                     ,layout: "fit"
                                     ,maximizable: true
                                     ,items: [form]
                             });
                     }
                     win.show();
                     win.center();
                     setWorkPlace();
                }
            }
            ,"-",{
                text: "เพิ่มกลุ่มผู้ใช้งาน(สสจ.)"
                ,iconCls: "table-add"
                ,hidden: (type_group_user == "2")? false : true
                ,handler: function(){
                     if(!form){
                             var form = new Ext.FormPanel({ 
                                     labelWidth: 80
                                     ,autoScroll: true
                                     ,url: pre_url + '/manage_user/create'
                                     ,frame: true
                                     ,monitorValid: true
                                     ,bodyStyle: "padding:10px"
                                     ,items:[
                                        {
                                            xtype: "textfield"
                                            ,fieldLabel: "ชื่อกลุ่มผู้ใช้งาน"
                                            ,id: "group_user[name]"
                                            ,anchor: "95%"
                                            ,allowBlank: false
                                        }
                                        ,new Ext.ux.form.PisComboBox({//กระทรวง
                                            fieldLabel: "กระทรวง"
                                            ,hiddenName: 'group_user[mcode]'
                                            ,id: 'group_user[mcode]'
                                            ,valueField: 'mcode'
                                            ,displayField: 'minname'
                                            ,urlStore: pre_url + '/code/cministry'
                                            ,fieldStore: ['mcode', 'minname']
                                            ,anchor: "95%"                                                               
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กรม
                                            fieldLabel: "กรม"
                                            ,hiddenName: 'group_user[deptcode]'
                                            ,id: 'group_user[deptcode]'
                                            ,valueField: 'deptcode'
                                            ,displayField: 'deptname'
                                            ,urlStore: pre_url + '/code/cdept'
                                            ,fieldStore: ['deptcode', 'deptname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กอง
                                            fieldLabel: "กอง"
                                            ,hiddenName: 'group_user[dcode]'
                                            ,id: 'group_user[dcode]'
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
                                                 ,anchor: "100%"
                                                 ,items: [
                                                          {
                                                                   xtype: "numberfield"
                                                                   ,id: "group_user[sdcode]"
                                                                   ,width: 80
                                                                   ,enableKeyEvents: true
                                                                   ,allowBlank: false
                                                                   ,listeners: {
                                                                            keyup: function( el,e ){
                                                                                Ext.getCmp("user_subdept_show").setValue("");
                                                                            }
                                                                            ,specialkey : function( el,e ){
                                                                                     
                                                                                     if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
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
                                                                                                       Ext.getCmp("group_user[sdcode]").setValue("");
                                                                                                       Ext.getCmp("user_subdept_show").setValue("");
                                                                                                    }
                                                                                                    else{
                                                                                                       Ext.getCmp("group_user[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                       Ext.getCmp("user_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                                                     if (Ext.getCmp("user_subdept_show").getValue() == ""){
                                                                                              Ext.getCmp("group_user[sdcode]").setValue("");
                                                                                              Ext.getCmp("user_subdept_show").setValue("");    
                                                                                     }
                                                                            }
                                                                            
                                                                   }
                                                          }
                                                          ,{
                                                                   xtype: "textarea"
                                                                   ,id: "user_subdept_show"
                                                                   ,readOnly: true
                                                                   ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                                                   ,width: 240
                                                                   ,height: 50
                                                          }
                                                          ,{
                                                                   xtype: "button"
                                                                   ,id: "user_subdept_button"
                                                                   ,text: ")..."
                                                                   ,handler: function(){
                                                                            searchSubdept(Ext.getCmp("group_user[sdcode]"),Ext.getCmp("user_subdept_show"));
                                                                   }
                                                          }
                                                 ]
                                        }
                                        /*,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                            fieldLabel: "ฝ่าย/กลุ่มงาน"
                                            ,hiddenName: 'group_user[seccode]'
                                            ,id: 'group_user[seccode]'
                                            ,valueField: 'seccode'
                                            ,displayField: 'secname'
                                            ,urlStore: pre_url + '/code/csection'
                                            ,fieldStore: ['seccode', 'secname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//งาน
                                            fieldLabel: "งาน"
                                            ,hiddenName: 'group_user[jobcode]'
                                            ,id: 'group_user[jobcode]'
                                            ,valueField: 'jobcode'
                                            ,displayField: 'jobname'
                                            ,urlStore: pre_url + '/code/cjob'
                                            ,fieldStore: ['jobcode', 'jobname']
                                            ,anchor: "95%"
                                        })*/
                                             ,new Ext.ux.form.PisComboBox({//จังหวัด
                                                      fieldLabel: 'จังหวัด'
                                                      ,hiddenName: 'group_user[provcode]'
                                                      ,id: 'group_user[provcode]'
                                                      ,valueField: 'provcode'
                                                      ,displayField: 'provname'
                                                      ,urlStore: pre_url + '/code/cprovince'
                                                      ,fieldStore: ['provcode', 'provname']
                                                      ,anchor: "100%"
                                                      ,allowBlank: false
                                             })
                                        
                                        ,{
                                            xtype: "checkboxgroup"
                                            ,fieldLabel: "สมารถใช้งาน"
                                            ,columns: 2
                                            ,items: [
                                                { xtype: "xcheckbox" ,boxLabel: "รหัสข้อมูล",id: "group_user[menu_code]",submitOffValue:'0',submitOnValue:'1' ,hidden: (group_user_admin == '1')? false:true}
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ผู้ใช้งาน",id: "group_user[menu_manage_user]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "รายงาน",id: "group_user[menu_report]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "บันทึกคำสั่ง",id: "group_user[menu_command]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "สอบถามข้อมูล",id: "group_user[menu_search]",submitOffValue:'0',submitOnValue:'1' }
                                            ]
                                        }
                                        ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลบุคคล",id: "group_user[menu_personal_info]",submitOffValue:'0',submitOnValue:'1'
                                            ,listeners: {
                                                check: function(el,check){
                                                    if (check){
                                                        Ext.getCmp("menu_detail_info").enable();
                                                    }else{
                                                        Ext.getCmp("menu_detail_info").setValue(['0','0','0','0','0','0','0','0','0']);
                                                        Ext.getCmp("menu_detail_info").disable();
                                                    }
                                                }
                                            }
                                        }
                                        ,{
                                            xtype: "checkboxgroup"
                                            ,hideLabel: true
                                            ,columns: 2
                                            ,id: "menu_detail_info"
                                            ,disabled: true
                                            ,style: "margin-left:100px"
                                            ,items: [
                                                { xtype: "xcheckbox" ,boxLabel: "ข้อมูลตำแหน่ง(จ.18)",id: "group_user[menu_pisj18]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ปฏิบัติราชการปัจจุบัน",id: "group_user[menu_perform_now]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติการรับราชการ",id: "group_user[menu_pisposhis]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลส่วนตัว",id: "group_user[menu_pispersonel]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "การศึกษา",id: "group_user[menu_piseducation]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "การลา",id: "group_user[menu_pisabsent]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "การประชุม/อบรม",id: "group_user[menu_pistrain]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติเครื่อราชย์",id: "group_user[menu_pisinsig]",submitOffValue:'0',submitOnValue:'1' }
                                                ,{ xtype: "xcheckbox" ,boxLabel: "โทษทางวินัย",id: "group_user[menu_pispunish]",submitOffValue:'0',submitOnValue:'1' }
                                            ]
                                        }
                                        ,{ fieldLabel: "ผู้ดูแลระบบ",xtype: "xcheckbox" ,boxLabel: "ใช่/ไม่ใช่",id: "group_user[admin]",submitOffValue:'0',submitOnValue:'1',hidden: (group_user_admin == '1')? false:true }
                                        ,{
                                             xtype: "hidden"
                                             ,id: "group_user[type_group]"
                                             ,value: "1"
                                        }
                                    ]
                                    ,buttons:[
                                             { 
                                                     text:'บันทึก'
                                                     ,formBind: true 
                                                     ,handler:function(){
                                                               if (Ext.getCmp("group_user[menu_command]").getValue() == true && Ext.getCmp("group_user[sdcode]").getValue() == ""){
                                                                        Ext.Msg.alert("คำเตือน","ถ้าเลือก  สามารถใช้งาน \"บันทึกคำสั่ง\" ต้องกำหนด หน่วยงานด้วย")
                                                                        return false;
                                                               }
                                                             form.getForm().submit({ 
                                                                     method:'POST'
                                                                     ,waitTitle:'Saving Data'
                                                                     ,waitMsg:'Sending data...'
                                                                     ,success:function(){		
                                                                             Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                                             if (btn == 'ok')
                                                                                             {
                                                                                                        userGroupGridStore.reload();
                                                                                                        win.close();											
                                                                                             }	
                                                                                     }
                                                                             );                                          
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
                                                     ,handler: function	(){
                                                             win.close();
                                                     }
                                             }
                                     ] 
                             });
                     }//end if form
                     if(!win){
                             var win = new Ext.Window({
                                     title: 'เพิ่มกลุ่มผู้ใช้งาน(สสจ.)'
                                     ,width: 500
                                     ,height: 500
                                     ,closable: true
                                     ,resizable: false
                                     ,plain: true
                                     ,border: false
                                     ,draggable: true 
                                     ,modal: true
                                     ,layout: "fit"
                                     ,maximizable: true
                                     ,items: [form]
                             });
                     }
                     win.show();
                     win.center();
                     setWorkPlaceSSJ();
                }
            }
            
        ]
});
userGroupGrid.on('rowdblclick', function(grid, rowIndex, e ) {
    data_select = grid.getSelectionModel().getSelected().data;
    userGrid.enable();
    userGridStore.baseParams = {
             group_user_id: data_select.id
    };
    userGridStore.load({params:{start:0,limit:20}})
    if (data_select.type_group == "1"){
         editUserRPT(data_select);
    }
    else if (data_select.type_group == "2"){
         editUserSSJ(data_select);
    }
});

function editUserSSJ(data_select){
    if(!form){
        var form = new Ext.FormPanel({ 
            labelWidth: 80
            ,autoScroll: true
            ,url: pre_url + '/manage_user/edit'
            ,frame: true
            ,monitorValid: true
            ,bodyStyle: "padding:10px"
            ,items:[
                {
                    xtype: "hidden"
                    ,id: "id"
                    ,value: data_select.id
                }
               ,{
                   xtype: "textfield"
                   ,fieldLabel: "ชื่อกลุ่มผู้ใช้งาน"
                   ,id: "group_user[name]"
                   ,anchor: "95%"
                   ,value: data_select.name
               }
               ,new Ext.ux.form.PisComboBox({//กระทรวง
                   fieldLabel: "กระทรวง"
                   ,hiddenName: 'group_user[mcode]'
                   ,id: 'group_user[mcode]'
                   ,valueField: 'mcode'
                   ,displayField: 'minname'
                   ,urlStore: pre_url + '/code/cministry'
                   ,fieldStore: ['mcode', 'minname']
                   ,anchor: "95%"                                                               
               })
               ,new Ext.ux.form.PisComboBox({//กรม
                   fieldLabel: "กรม"
                   ,hiddenName: 'group_user[deptcode]'
                   ,id: 'group_user[deptcode]'
                   ,valueField: 'deptcode'
                   ,displayField: 'deptname'
                   ,urlStore: pre_url + '/code/cdept'
                   ,fieldStore: ['deptcode', 'deptname']
                   ,anchor: "95%"
               })
               ,new Ext.ux.form.PisComboBox({//กอง
                   fieldLabel: "กอง"
                   ,hiddenName: 'group_user[dcode]'
                   ,id: 'group_user[dcode]'
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
                        ,anchor: "100%"
                        ,items: [
                                 {
                                          xtype: "numberfield"
                                          ,id: "group_user[sdcode]"
                                          ,width: 80
                                          ,enableKeyEvents: true
                                          ,allowBlank: false
                                          ,value: data_select.sdcode
                                          ,listeners: {
                                                    keyup: function( el,e ){
                                                        Ext.getCmp("user_subdept_show").setValue("");
                                                    }
                                                   ,specialkey : function( el,e ){
                                                            
                                                            if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
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
                                                                              Ext.getCmp("group_user[sdcode]").setValue("");
                                                                              Ext.getCmp("user_subdept_show").setValue("");
                                                                           }
                                                                           else{
                                                                              Ext.getCmp("group_user[sdcode]").setValue(obj.records[0].sdcode);
                                                                              Ext.getCmp("user_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                            if (Ext.getCmp("user_subdept_show").getValue() == ""){
                                                                     Ext.getCmp("group_user[sdcode]").setValue("");
                                                                     Ext.getCmp("user_subdept_show").setValue("");    
                                                            }
                                                   }
                                                   
                                          }
                                 }
                                 ,{
                                          xtype: "textarea"
                                          ,id: "user_subdept_show"
                                          ,readOnly: true
                                          ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                          ,width: 240
                                          ,height: 50
                                          ,value: data_select.user_subdept_show
                                 }
                                 ,{
                                          xtype: "button"
                                          ,id: "user_subdept_button"
                                          ,text: ")..."
                                          ,handler: function(){
                                                   searchSubdept(Ext.getCmp("group_user[sdcode]"),Ext.getCmp("user_subdept_show"));
                                          }
                                 }
                        ]
               }
               /*,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                   fieldLabel: "ฝ่าย/กลุ่มงาน"
                   ,hiddenName: 'group_user[seccode]'
                   ,id: 'group_user[seccode]'
                   ,valueField: 'seccode'
                   ,displayField: 'secname'
                   ,urlStore: pre_url + '/code/csection'
                   ,fieldStore: ['seccode', 'secname']
                   ,anchor: "95%"
               })
               ,new Ext.ux.form.PisComboBox({//งาน
                   fieldLabel: "งาน"
                   ,hiddenName: 'group_user[jobcode]'
                   ,id: 'group_user[jobcode]'
                   ,valueField: 'jobcode'
                   ,displayField: 'jobname'
                   ,urlStore: pre_url + '/code/cjob'
                   ,fieldStore: ['jobcode', 'jobname']
                   ,anchor: "95%"
               })*/
                  ,new Ext.ux.form.PisComboBox({//จังหวัด
                           fieldLabel: 'จังหวัด'
                           ,hiddenName: 'group_user[provcode]'
                           ,id: 'group_user[provcode]'
                           ,valueField: 'provcode'
                           ,displayField: 'provname'
                           ,urlStore: pre_url + '/code/cprovince'
                           ,fieldStore: ['provcode', 'provname']
                           ,anchor: "100%"
                           ,allowBlank: false
                  })
               ,{
                   xtype: "checkboxgroup"
                   ,fieldLabel: "สมารถใช้งาน"
                   ,columns: 2
                   ,items: [
                       { xtype: "xcheckbox" ,boxLabel: "รหัสข้อมูล",id: "group_user[menu_code]",submitOffValue:'0',submitOnValue:'1',hidden: (group_user_admin == '1')? false:true }
                       ,{ xtype: "xcheckbox" ,boxLabel: "ผู้ใช้งาน",id: "group_user[menu_manage_user]",submitOffValue:'0',submitOnValue:'1' }
                       ,{ xtype: "xcheckbox" ,boxLabel: "รายงาน",id: "group_user[menu_report]",submitOffValue:'0',submitOnValue:'1' }
                       ,{ xtype: "xcheckbox" ,boxLabel: "บันทึกคำสั่ง",id: "group_user[menu_command]",submitOffValue:'0',submitOnValue:'1' }
                       ,{ xtype: "xcheckbox" ,boxLabel: "สอบถามข้อมูล",id: "group_user[menu_search]",submitOffValue:'0',submitOnValue:'1' }
                   ]
               }
               ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลบุคคล",id: "group_user[menu_personal_info]",submitOffValue:'0',submitOnValue:'1'
                    ,listeners: {
                        check: function(el,check){
                            if (check){
                                Ext.getCmp("menu_detail_info").enable();
                            }else{
                                Ext.getCmp("menu_detail_info").setValue(['0','0','0','0','0','0','0','0','0']);
                                Ext.getCmp("menu_detail_info").disable();
                            }
                        }
                    }
                }
                ,{
                    xtype: "checkboxgroup"
                    ,hideLabel: true
                    ,columns: 2
                    ,id: "menu_detail_info"
                    ,disabled: true
                    ,style: "margin-left:100px"
                    ,items: [
                        { xtype: "xcheckbox" ,boxLabel: "ข้อมูลตำแหน่ง(จ.18)",id: "group_user[menu_pisj18]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ปฏิบัติราชการปัจจุบัน",id: "group_user[menu_perform_now]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติการรับราชการ",id: "group_user[menu_pisposhis]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลส่วนตัว",id: "group_user[menu_pispersonel]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "การศึกษา",id: "group_user[menu_piseducation]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "การลา",id: "group_user[menu_pisabsent]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "การประชุม/อบรม",id: "group_user[menu_pistrain]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติเครื่อราชย์",id: "group_user[menu_pisinsig]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "โทษทางวินัย",id: "group_user[menu_pispunish]",submitOffValue:'0',submitOnValue:'1' }
                    ]
                }
               ,{ fieldLabel: "ผู้ดูแลระบบ",xtype: "xcheckbox" ,boxLabel: "ใช่/ไม่ใช่",id: "group_user[admin]",submitOffValue:'0',submitOnValue:'1',hidden: (group_user_admin == '1')? false:true }
           ]
           ,buttons:[
                    { 
                            text:'บันทึก'
                            ,formBind: true 
                            ,handler:function(){
                                    if (Ext.getCmp("group_user[menu_command]").getValue() == true && Ext.getCmp("group_user[sdcode]").getValue() == ""){
                                             Ext.Msg.alert("คำเตือน","ถ้าเลือก  สามารถใช้งาน \"บันทึกคำสั่ง\" ต้องกำหนด หน่วยงานด้วย")
                                             return false;
                                    }
                                    form.getForm().submit(
                                    { 
                                            method:'POST'
                                            ,waitTitle:'Saving Data'
                                            ,waitMsg:'Sending data...'
                                            ,success:function(){		
                                                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                    if (btn == 'ok')
                                                                    {
                                                                               userGroupGridStore.reload();
                                                                               win.close();											
                                                                    }	
                                                            }
                                                    );                                          
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
                            ,handler: function	(){
                                    win.close();
                            }
                    }
            ] 
        });
    }//end if form
    if(!win){
        var win = new Ext.Window({
            title: 'แก้ไขกลุ่มผู้ใช้งาน(สสจ.)'
            ,width: 500
            ,height: 500
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,maximizable: true
            ,items: [form]
        });
    }
    loadMask.show();   
    Ext.getCmp("group_user[mcode]").getStore().load({
            params: {
                     mcode: data_select.mcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("group_user[mcode]").setValue(data_select.mcode);
            }
   });    
    Ext.getCmp("group_user[deptcode]").getStore().load({
            params: {
                     deptcode: data_select.deptcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("group_user[deptcode]").setValue(data_select.deptcode);
            }
   });
    Ext.getCmp("group_user[dcode]").getStore().load({
            params: {
                     dcode: data_select.dcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("group_user[dcode]").setValue(data_select.dcode);
            }
   });    
    Ext.getCmp("group_user[provcode]").getStore().load({
            params: {
                     provcode: data_select.provcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                    Ext.getCmp("group_user[provcode]").setValue(data_select.provcode);
                    loadMask.hide();
                    win.show();
                    win.center();
                    Ext.getCmp("group_user[menu_code]").setValue(data_select.menu_code);
                    Ext.getCmp("group_user[menu_personal_info]").setValue(data_select.menu_personal_info);
                    Ext.getCmp("group_user[menu_pisj18]").setValue(data_select.menu_pisj18);
                    Ext.getCmp("group_user[menu_perform_now]").setValue(data_select.menu_perform_now);
                    Ext.getCmp("group_user[menu_pisposhis]").setValue(data_select.menu_pisposhis);
                    Ext.getCmp("group_user[menu_pispersonel]").setValue(data_select.menu_pispersonel);
                    Ext.getCmp("group_user[menu_piseducation]").setValue(data_select.menu_piseducation);
                    Ext.getCmp("group_user[menu_pisabsent]").setValue(data_select.menu_pisabsent);
                    Ext.getCmp("group_user[menu_pistrain]").setValue(data_select.menu_pistrain);
                    Ext.getCmp("group_user[menu_pisinsig]").setValue(data_select.menu_pisinsig);
                    Ext.getCmp("group_user[menu_pispunish]").setValue(data_select.menu_pispunish);
                    Ext.getCmp("group_user[menu_manage_user]").setValue(data_select.menu_manage_user);
                    Ext.getCmp("group_user[menu_report]").setValue(data_select.menu_report);
                    Ext.getCmp("group_user[menu_command]").setValue(data_select.menu_command);
                    Ext.getCmp("group_user[menu_search]").setValue(data_select.menu_search);
                    Ext.getCmp("group_user[admin]").setValue(data_select.admin);
            }
   });    
    //setReadOnlyWorkPlace();         
}
function editUserRPT(data_select){
    if(!form){
        var form = new Ext.FormPanel({ 
            labelWidth: 80
            ,autoScroll: true
            ,url: pre_url + '/manage_user/edit'
            ,frame: true
            ,monitorValid: true
            ,bodyStyle: "padding:10px"
            ,items:[
                {
                    xtype: "hidden"
                    ,id: "id"
                    ,value: data_select.id
                }
               ,{
                   xtype: "textfield"
                   ,fieldLabel: "ชื่อกลุ่มผู้ใช้งาน"
                   ,id: "group_user[name]"
                   ,anchor: "95%"
                   ,value: data_select.name
               }
               ,new Ext.ux.form.PisComboBox({//กระทรวง
                   fieldLabel: "กระทรวง"
                   ,hiddenName: 'group_user[mcode]'
                   ,id: 'group_user[mcode]'
                   ,valueField: 'mcode'
                   ,displayField: 'minname'
                   ,urlStore: pre_url + '/code/cministry'
                   ,fieldStore: ['mcode', 'minname']
                   ,anchor: "95%"                                                               
               })
               ,new Ext.ux.form.PisComboBox({//กรม
                   fieldLabel: "กรม"
                   ,hiddenName: 'group_user[deptcode]'
                   ,id: 'group_user[deptcode]'
                   ,valueField: 'deptcode'
                   ,displayField: 'deptname'
                   ,urlStore: pre_url + '/code/cdept'
                   ,fieldStore: ['deptcode', 'deptname']
                   ,anchor: "95%"
               })
               ,new Ext.ux.form.PisComboBox({//กอง
                   fieldLabel: "กอง"
                   ,hiddenName: 'group_user[dcode]'
                   ,id: 'group_user[dcode]'
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
                        ,anchor: "100%"
                        ,items: [
                                 {
                                          xtype: "numberfield"
                                          ,id: "group_user[sdcode]"
                                          ,width: 80
                                          ,enableKeyEvents: true
                                          ,value: data_select.sdcode
                                          ,allowBlank: false
                                          ,listeners: {
                                                keyup: function( el,e ){
                                                    Ext.getCmp("user_subdept_show").setValue("");
                                                }
                                                   ,specialkey : function( el,e ){
                                                            
                                                            if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
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
                                                                              Ext.getCmp("group_user[sdcode]").setValue("");
                                                                              Ext.getCmp("user_subdept_show").setValue("");
                                                                           }
                                                                           else{
                                                                              Ext.getCmp("group_user[sdcode]").setValue(obj.records[0].sdcode);
                                                                              Ext.getCmp("user_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                            if (Ext.getCmp("user_subdept_show").getValue() == ""){
                                                                     Ext.getCmp("group_user[sdcode]").setValue("");
                                                                     Ext.getCmp("user_subdept_show").setValue("");    
                                                            }
                                                   }
                                                   
                                          }
                                 }
                                 ,{
                                          xtype: "textarea"
                                          ,id: "user_subdept_show"
                                          ,readOnly: true
                                          ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                          ,width: 240
                                          ,height: 50
                                          ,value: data_select.user_subdept_show
                                 }
                                 ,{
                                          xtype: "button"
                                          ,id: "user_subdept_button"
                                          ,text: ")..."
                                          ,handler: function(){
                                                   searchSubdept(Ext.getCmp("group_user[sdcode]"),Ext.getCmp("user_subdept_show"));
                                          }
                                 }
                        ]
               }
               ,{
                   xtype: "checkboxgroup"
                   ,fieldLabel: "สมารถใช้งาน"
                   ,columns: 2
                   ,items: [
                       { xtype: "xcheckbox" ,boxLabel: "รหัสข้อมูล",id: "group_user[menu_code]",submitOffValue:'0',submitOnValue:'1',hidden: (group_user_admin == '1')? false:true }
                       ,{ xtype: "xcheckbox" ,boxLabel: "ผู้ใช้งาน",id: "group_user[menu_manage_user]",submitOffValue:'0',submitOnValue:'1' }
                       ,{ xtype: "xcheckbox" ,boxLabel: "รายงาน",id: "group_user[menu_report]",submitOffValue:'0',submitOnValue:'1' }
                       ,{ xtype: "xcheckbox" ,boxLabel: "บันทึกคำสั่ง",id: "group_user[menu_command]",submitOffValue:'0',submitOnValue:'1' }
                       ,{ xtype: "xcheckbox" ,boxLabel: "สอบถามข้อมูล",id: "group_user[menu_search]",submitOffValue:'0',submitOnValue:'1' }
                   ]
               }
               ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลบุคคล",id: "group_user[menu_personal_info]",submitOffValue:'0',submitOnValue:'1'
                    ,listeners: {
                        check: function(el,check){
                            if (check){
                                Ext.getCmp("menu_detail_info").enable();
                            }else{
                                Ext.getCmp("menu_detail_info").setValue(['0','0','0','0','0','0','0','0','0']);
                                Ext.getCmp("menu_detail_info").disable();
                            }
                        }
                    }
                }
                ,{
                    xtype: "checkboxgroup"
                    ,hideLabel: true
                    ,columns: 2
                    ,id: "menu_detail_info"
                    ,disabled: true
                    ,style: "margin-left:100px"
                    ,items: [
                        { xtype: "xcheckbox" ,boxLabel: "ข้อมูลตำแหน่ง(จ.18)",id: "group_user[menu_pisj18]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ปฏิบัติราชการปัจจุบัน",id: "group_user[menu_perform_now]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติการรับราชการ",id: "group_user[menu_pisposhis]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ข้อมูลส่วนตัว",id: "group_user[menu_pispersonel]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "การศึกษา",id: "group_user[menu_piseducation]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "การลา",id: "group_user[menu_pisabsent]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "การประชุม/อบรม",id: "group_user[menu_pistrain]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ประวัติเครื่อราชย์",id: "group_user[menu_pisinsig]",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "โทษทางวินัย",id: "group_user[menu_pispunish]",submitOffValue:'0',submitOnValue:'1' }
                    ]
                }
               ,{ fieldLabel: "ผู้ดูแลระบบ",xtype: "xcheckbox" ,boxLabel: "ใช่/ไม่ใช่",id: "group_user[admin]",submitOffValue:'0',submitOnValue:'1',hidden: (group_user_admin == '1')? false:true }
           ]
           ,buttons:[
                    { 
                            text:'บันทึก'
                            ,formBind: true 
                            ,handler:function(){
                                    if (Ext.getCmp("group_user[menu_command]").getValue() == true && Ext.getCmp("group_user[sdcode]").getValue() == ""){
                                             Ext.Msg.alert("คำเตือน","ถ้าเลือก  สามารถใช้งาน \"บันทึกคำสั่ง\" ต้องกำหนด หน่วยงานด้วย")
                                             return false;
                                    }
                                    form.getForm().submit(
                                    { 
                                            method:'POST'
                                            ,waitTitle:'Saving Data'
                                            ,waitMsg:'Sending data...'
                                            ,success:function(){		
                                                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                    if (btn == 'ok')
                                                                    {
                                                                               userGroupGridStore.reload();
                                                                               win.close();											
                                                                    }	
                                                            }
                                                    );                                          
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
                            ,handler: function	(){
                                    win.close();
                            }
                    }
            ] 
        });
    }//end if form
    if(!win){
        var win = new Ext.Window({
            title: 'แก้ไขกลุ่มผู้ใช้งาน(รพศ,รพท)'
            ,width: 500
            ,height: 500
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,maximizable: true
            ,items: [form]
        });
    }
    loadMask.show();   
    Ext.getCmp("group_user[mcode]").getStore().load({
            params: {
                     mcode: data_select.mcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("group_user[mcode]").setValue(data_select.mcode);
            }
   });    
    Ext.getCmp("group_user[deptcode]").getStore().load({
            params: {
                     deptcode: data_select.deptcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("group_user[deptcode]").setValue(data_select.deptcode);
            }
   });
    Ext.getCmp("group_user[dcode]").getStore().load({
            params: {
                     dcode: data_select.dcode
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("group_user[dcode]").setValue(data_select.dcode);
                     loadMask.hide();
                    win.show();
                    win.center();
                    Ext.getCmp("group_user[menu_code]").setValue(data_select.menu_code);
                    Ext.getCmp("group_user[menu_personal_info]").setValue(data_select.menu_personal_info);
                    Ext.getCmp("group_user[menu_pisj18]").setValue(data_select.menu_pisj18);
                    Ext.getCmp("group_user[menu_perform_now]").setValue(data_select.menu_perform_now);
                    Ext.getCmp("group_user[menu_pisposhis]").setValue(data_select.menu_pisposhis);
                    Ext.getCmp("group_user[menu_pispersonel]").setValue(data_select.menu_pispersonel);
                    Ext.getCmp("group_user[menu_piseducation]").setValue(data_select.menu_piseducation);
                    Ext.getCmp("group_user[menu_pisabsent]").setValue(data_select.menu_pisabsent);
                    Ext.getCmp("group_user[menu_pistrain]").setValue(data_select.menu_pistrain);
                    Ext.getCmp("group_user[menu_pisinsig]").setValue(data_select.menu_pisinsig);
                    Ext.getCmp("group_user[menu_pispunish]").setValue(data_select.menu_pispunish);
                    Ext.getCmp("group_user[menu_manage_user]").setValue(data_select.menu_manage_user);
                    Ext.getCmp("group_user[menu_report]").setValue(data_select.menu_report);
                    Ext.getCmp("group_user[menu_command]").setValue(data_select.menu_command);
                    Ext.getCmp("group_user[menu_search]").setValue(data_select.menu_search);
                    Ext.getCmp("group_user[admin]").setValue(data_select.admin);
            }
   });    
    setReadOnlyWorkPlace();         
}
/*********************************************************************************************/
// user
/***************************************************************************************/
var userFields = [
    {name: "id", type: "int"}
    ,{name: "username",type: "string"}
    ,{name: "email",type: "string"}
    ,{name: "fname",type: "string"}
    ,{name: "lname",type: "string"}
    ,{name: "group_user_id",type: "string"}   
];

var userCols = [
        {
              header: "#"
              ,width: 30
              ,renderer: rowNumberer.createDelegate(this)
              ,sortable: false
        }		
        ,{header: "Username",width: 120, sortable: false, dataIndex: 'username'}
        ,{header: "Email",width: 120, sortable: false, dataIndex: 'email'}
        ,{header: "ชื่อ",width: 120, sortable: false, dataIndex: 'fname'}
        ,{header: "นามสกุล",width: 120, sortable: false, dataIndex: 'lname'}
];

var userGridStore = new Ext.data.JsonStore({
        url: pre_url + "/manage_user/read_user"
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: userFields
        ,idProperty: 'id'
});

var userGrid = new Ext.grid.GridPanel({
        title: "ผู้ใช้งาน"
        ,disabled: true
        ,region: 'center'
        ,split: true
        ,store: userGridStore
        ,columns: userCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
        ,bbar: new Ext.PagingToolbar({
                        pageSize: 20
                        ,autoWidth: true
                        ,store: userGridStore
                        ,displayInfo: true
                        ,displayMsg	: 'Displaying {0} - {1} of {2}'
                        ,emptyMsg: "Not found"
        })
        ,tbar: [
              {
                       text: "เพิ่มผู้ใช้งาน"
                       ,iconCls: "table-add"
                       ,handler: function(){
                                if(!form){
                                        var form = new Ext.FormPanel({ 
                                                  labelWidth: 110
                                                  ,autoScroll: true
                                                  ,url: pre_url + '/manage_user/create_user'
                                                  ,frame: true
                                                  ,monitorValid: true
                                                  ,bodyStyle: "padding:10px"
                                                  ,items:[
                                                           {
                                                                xtype: "hidden"
                                                                ,id: "user[group_user_id]"
                                                                ,value: userGroupGrid.getSelectionModel().getSelected().data.id
                                                           }
                                                           ,{
                                                                    xtype: "textfield"
                                                                    ,id: "user[username]"
                                                                    ,fieldLabel: "Username"
                                                                    ,anchor: "95%"
                                                                    ,allowBlank: false
                                                           }
                                                           ,{
                                                                    xtype: "textfield"
                                                                    ,id: "user[email]"
                                                                    ,fieldLabel: "Email"
                                                                    ,vtype: "email"
                                                                    ,msgTarget: "side"
                                                                    ,anchor: "95%"
                                                                    ,allowBlank: false
                                                           }
                                                           ,{
                                                                    xtype: "textfield"
                                                                    ,inputType: 'password'
                                                                    ,id: "user[password]"
                                                                    ,fieldLabel: "Password"
                                                                    ,anchor: "95%"
                                                                    ,allowBlank: false
                                                           }
                                                           ,{
                                                                    xtype: "textfield"
                                                                    ,inputType: 'password'
                                                                    ,id: "user[password_confirmation]"
                                                                    ,fieldLabel: "Confirm Password"
                                                                    ,vtype: 'password'
                                                                    ,initialPassField: 'user[password]'
                                                                    ,msgTarget: "side"
                                                                    ,anchor: "95%"
                                                                    ,allowBlank: false
                                                           }
                                                           ,{
                                                                    xtype: "textfield"
                                                                    ,id: "user[fname]"
                                                                    ,fieldLabel: "ชื่อ"
                                                                    ,anchor: "95%"
                                                                    ,allowBlank: false
                                                           }
                                                           ,{
                                                                    xtype: "textfield"
                                                                    ,id: "user[lname]"
                                                                    ,fieldLabel: "นามสกุล"
                                                                    ,anchor: "95%"
                                                                    ,allowBlank: false
                                                           }
                                                  ]
                                                  ,buttons:[
                                                          { 
                                                                  text:'บันทึก'
                                                                  ,formBind: true 
                                                                  ,handler:function(){
                                                                          form.getForm().submit(
                                                                          { 
                                                                                  method:'POST'
                                                                                  ,waitTitle:'Saving Data'
                                                                                  ,waitMsg:'Sending data...'
                                                                                  ,success:function(){		
                                                                                          Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                                                          if (btn == 'ok')
                                                                                                          {
                                                                                                                     userGridStore.reload();
                                                                                                                     win.close();											
                                                                                                          }	
                                                                                                  }
                                                                                          );                                          
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
                                                                  ,handler: function	(){
                                                                          win.close();
                                                                  }
                                                          }
                                                  ] 
                                        });
                                }//end if form
                                if(!win){
                                        var win = new Ext.Window({
                                                title: 'เพิ่มผู้ใช้งาน'
                                                ,width: 400
                                                ,height: 300
                                                ,closable: true
                                                ,resizable: false
                                                ,plain: true
                                                ,border: false
                                                ,draggable: true 
                                                ,modal: true
                                                ,layout: "fit"
                                                ,maximizable: true
                                                ,items: [form]
                                        });
                                }
                                win.show();
                                win.center();                                    
                       }
              }
        ]
});
userGrid.on('rowdblclick', function(grid, rowIndex, e ) {
     data_select = grid.getSelectionModel().getSelected().data;
     if(!form){
             var form = new Ext.FormPanel({ 
                       labelWidth: 110
                       ,autoScroll: true
                       ,url: pre_url + '/manage_user/edit_user'
                       ,frame: true
                       ,monitorValid: true
                       ,bodyStyle: "padding:10px"
                       ,items:[
                                {
                                         xtype: "textfield"
                                         ,id: "user[username]"
                                         ,fieldLabel: "Username"
                                         ,anchor: "95%"
                                         ,value: data_select.username
                                         ,allowBlank: false
                                }
                                ,{
                                         xtype: "textfield"
                                         ,id: "user[email]"
                                         ,fieldLabel: "Email"
                                         ,vtype: "email"
                                         ,msgTarget: "side"
                                         ,anchor: "95%"
                                         ,value: data_select.email
                                         ,allowBlank: false
                                }
                                ,{
                                         xtype: "textfield"
                                         ,inputType: 'password'
                                         ,id: "user[password]"
                                         ,fieldLabel: "Password"
                                         ,anchor: "95%"
                                         ,allowBlank: false
                                }
                                ,{
                                         xtype: "textfield"
                                         ,inputType: 'password'
                                         ,id: "user[password_confirmation]"
                                         ,fieldLabel: "Confirm Password"
                                         ,vtype: 'password'
                                         ,initialPassField: 'user[password]'
                                         ,msgTarget: "side"
                                         ,anchor: "95%"
                                         ,allowBlank: false
                                }
                                ,{
                                         xtype: "textfield"
                                         ,id: "user[fname]"
                                         ,fieldLabel: "ชื่อ"
                                         ,anchor: "95%"
                                         ,value: data_select.fname
                                         ,allowBlank: false
                                }
                                ,{
                                         xtype: "textfield"
                                         ,id: "user[lname]"
                                         ,fieldLabel: "นามสกุล"
                                         ,anchor: "95%"
                                         ,value: data_select.lname
                                         ,allowBlank: false
                                }
                       ]
                       ,buttons:[
                               { 
                                       text:'บันทึก'
                                       ,formBind: true 
                                       ,handler:function(){ 					
                                               form.getForm().submit(
                                               { 
                                                       method:'POST'
                                                       ,waitTitle:'Saving Data'
                                                       ,waitMsg:'Sending data...'
                                                       ,params: {
                                                           "user[group_user_id]": userGroupGrid.getSelectionModel().getSelected().data.id
                                                           ,id: data_select.id
                                                       }
                                                       ,success:function(){		
                                                               Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                               if (btn == 'ok')
                                                                               {
                                                                                          userGridStore.reload();
                                                                                          win.close();											
                                                                               }	
                                                                       }
                                                               );                                          
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
                                       ,handler: function	(){
                                               win.close();
                                       }
                               }
                       ] 
             });
     }//end if form
     if(!win){
             var win = new Ext.Window({
                     title: 'แก้ไขผู้ใช้งาน'
                     ,width: 400
                     ,height: 300
                     ,closable: true
                     ,resizable: false
                     ,plain: true
                     ,border: false
                     ,draggable: true 
                     ,modal: true
                     ,layout: "fit"
                     ,maximizable: true
                     ,items: [form]
             });
     }
     win.show();
     win.center();                                    
});


var user_panel = new Ext.Panel({
    layout: "border"
    ,items: [
        userGroupGrid
        ,userGrid
    ]
    ,listeners: {
              afterrender: function(el){
                       userGroupGridStore.load({params:{limit:20,start:0}});
              }
    }
});    


