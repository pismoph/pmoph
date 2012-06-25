his_url = ""
/********************************************************************/
/*Grid*/
/******************************************************************/    
var data_pisposhisSearch = new Ext.ux.grid.Search({
         iconCls: 'search'
         ,minChars: 3
         ,autoFocus: true
         ,position: "top"
         ,width: 200
});
var data_pisposhisFields = [
         ,{name: "id", type: "string"}
         ,{name: "sex", type: "string"}
         ,{name: "prefix", type: "string"}
         ,{name: "fname", type: "string"}
         ,{name: "lname", type: "string"}
         ,{name: "pid", type: "string"}
         ,{name: "birthdate", type: "string"}
         ,{name: "tel", type: "string"}
         ,{name: "name", type: "string"}
         ,{name: "posid", type: "string"}
];
    
var data_pisposhisCols = [
     {
              header: "#"
              ,width: 80
              ,renderer: rowNumberer.createDelegate(this)
              ,sortable: false
     }
     ,{header: "เลขที่ตำแหน่ง",width: 100, sortable: false, dataIndex: 'posid'}
     ,{header: "คำนำหน้า",width: 70, sortable: false, dataIndex: 'prefix'}
     ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
     ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
     ,{header: "เลขบัตรประชาชน",width: 100, sortable: false, dataIndex: 'pid'}
     ,{header: "วันเกิด",width: 100, sortable: false, dataIndex: 'birthdate'}
     ,{header: "เพศ",width: 100, sortable: false, dataIndex: 'sex'}
     ,{header: "เบอร์โทรศัพท์",width: 100, sortable: false, dataIndex: 'tel'}
];
    
var data_pisposhisGridStore = new Ext.data.JsonStore({
         url: pre_url + "/info_personal/read"
         ,root: "records"
         ,autoLoad: false
         ,totalProperty	: 'totalCount'
         ,fields: data_pisposhisFields
         ,idProperty: 'id'
});
    
var data_pisposhisGrid = new Ext.grid.GridPanel({
         region: "center"
         ,split: true
         ,store: data_pisposhisGridStore
         ,columns: data_pisposhisCols
         ,stripeRows: true
         ,loadMask: {msg:'Loading...'}
         ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
         ,plugins: [data_pisposhisSearch]
         ,bbar: new Ext.PagingToolbar({
                  pageSize: 20
                  ,autoWidth: true
                  ,store: data_pisposhisGridStore
                  ,displayInfo: true
                  ,displayMsg: 'Displaying {0} - {1} of {2}'
                  ,emptyMsg: "Not found"
         })
         ,tbar: []
});
data_pisposhisGrid.on('rowdblclick', function(grid, rowIndex, e ) {     
         data_select = grid.getSelectionModel().getSelected().data;
         data_personel_id = data_select.id;
         searchEditPositionHist(data_select);
});

function searchEditPositionHist(data_select){
         tab_personel.getActiveTab().setTitle("ประวัติการรับราชการ ( " +data_select.name+ " )")
         detail_pisposhisGridStore.removeAll();
         panelPosHis.getLayout().setActiveItem(panelPosHisSecond);
         formDatailData_Pisposhis.getForm().reset();
         formDatailData_Pisposhis.disable();
         detail_pisposhisGridStore.baseParams = {
                  id: data_select.id
         }
         detail_pisposhisGridStore.load({params: {start: 0,limit:20}}) 
}

function searchPositionHistById(personel_id){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_personal/search_id"
                  ,params: {
                           id: personel_id
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           if (obj.data.length != 0){
                                    searchEditPositionHist(obj.data[0]);                                  
                           }
                           else{
                                    data_personel_id = "";
                                    panelPosHis.getLayout().setActiveItem(panelPosHisFirst);
                           }
                           loadMask.hide();
                  }
                  ,failure: function(response,opts){
                           Ext.Msg.alert("สถานะ",response.statusText);
                           loadMask.hide();
                  }
         });
}
/********************************************************************/
/*Form*/
/******************************************************************/
/////////////////////////////////// Grid Detail
var detail_pisposhisFields = [
        {name: "id", type: "string"}
        ,{name: "historder", type: "int"}
        ,{name: "forcedate", type: "string"}
        ,{name: "posid", type: "string"}
        ,{name: "posname", type: "string"}
        ,{name: "cname", type: "string"}
        ,{name: "salary", type: "string"}
        ,{name: "refcmnd", type: "string"}
        ,{name: "updname", type: "string"}
];
		
var detail_pisposhisCols = [
         {header: "ลำดับที่",width: 80, sortable: false, dataIndex: 'historder'}
         ,{header: "วันที่มีผลบังคับใช้",width: 150, sortable: false, dataIndex: 'forcedate'}
         ,{header: "เลขที่ตำแหน่ง",width: 100, sortable: false, dataIndex: 'posid'}
         ,{header: "ตำแหน่งสายงาน",width: 200, sortable: false, dataIndex: 'posname',renderer:function(val, x, store){
                           return val;
                  }
         }
         ,{header: "เงินเดือน",width: 100, sortable: false, dataIndex: 'salary'}
         ,{header: "คำสั่ง",width: 300, sortable: false, dataIndex: 'refcmnd',renderer:function(val, x, store){
                           return val + "<br />" + store.data.updname;
                  }
         }
];
		
var detail_pisposhisGridStore = new Ext.data.JsonStore({
         url: pre_url + "/info_pisposhis/read"
         ,root: "records"
         ,autoLoad: false
         ,totalProperty	: 'totalCount'
         ,fields: detail_pisposhisFields
         ,idProperty: 'historder'
});
		
var detail_pisposhisGrid = new Ext.grid.GridPanel({
         region: 'north'
         ,height: 200
         ,split: true
         ,store: detail_pisposhisGridStore
         ,columns: detail_pisposhisCols
         ,stripeRows: true
         ,loadMask: {msg:'Loading...'}
         ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
         ,bbar: new Ext.PagingToolbar({
                  pageSize: 20
                  ,autoWidth: true
                  ,store: detail_pisposhisGridStore
                  ,displayInfo: true
                  ,displayMsg: 'Displaying {0} - {1} of {2}'
                  ,emptyMsg: "Not found"
         })
         ,tbar: [
                  {
                           text: "เพิ่ม"
                           ,iconCls: "table-add"
                           ,handler: function(){
                                    his_url = pre_url + "/info_pisposhis/create"
                                    formDatailData_Pisposhis.enable();
                                    formDatailData_Pisposhis.getForm().reset();
                                    Ext.getCmp("id").setValue(data_personel_id);
                                    //setWorkPlace();
                           }
                  }
                  ,"-",{
                           ref: '../removeBtn'
                           ,text: 'ลบ'
                           ,tooltip: 'ลบ'
                           ,iconCls: 'table-delete'
                           ,disabled: true
                           ,handler: function(){
                                    Ext.MessageBox.confirm('คำเตือน', 'คุณต้องการลบข้อมูลนี้หรือไม', function(btn){
                                             if (btn == "yes"){
                                                      loadMask.show();
                                                      Ext.Ajax.request({
                                                               url: pre_url + "/info_pisposhis/delete"
                                                               ,params: {
                                                                        id: detail_pisposhisGrid.getSelectionModel().getSelected().data.id
                                                                        ,historder: detail_pisposhisGrid.getSelectionModel().getSelected().data.historder
                                                               }
                                                               ,success: function(response,opts){
                                                                        obj = Ext.util.JSON.decode(response.responseText);
                                                                        if (obj.success){
                                                                                 Ext.Msg.alert("สถานะ","ลบเสร็จเรียบร้อย");
                                                                                 detail_pisposhisGridStore.reload();
                                                                                 formDatailData_Pisposhis.getForm().reset();
                                                                                 formDatailData_Pisposhis.disable();
                                                                                 loadMask.hide();
                                                                        }else{
                                                                                 Ext.Msg.alert("สถานะ","กรุณาลองใหม่อีกครั้ง");
                                                                                 loadMask.hide();
                                                                        }
                                                                        
                                                               }
                                                               ,failure: function(response,opts){
                                                                        Ext.Msg.alert("สถานะ",response.statusText);
                                                                        loadMask.hide();
                                                               }
                                                      });                                                      
                                             }
                                    });
                           }
                  }
                  ,"-",{
                           text: "ปิด"
                           ,handler: function(){
                                    tab_personel.getActiveTab().setTitle("ประวัติการรับราชการ");
                                    data_personel_id = "";
                                    panelPosHis.getLayout().setActiveItem(panelPosHisFirst);
                           }
                  }
         ]
});
detail_pisposhisGrid.on('rowdblclick', function(grid, rowIndex, e ) {
         his_url = pre_url + "/info_pisposhis/edit"
         data_select = grid.getSelectionModel().getSelected().data;
         searchEditDataPisposhis(data_select.id,data_select.historder)
});

detail_pisposhisGrid.getSelectionModel().on('selectionchange', function(sm){			
         detail_pisposhisGrid.removeBtn.setDisabled(sm.getCount() < 1);		
});

//////////////////////////Form Deatil
var formDatailData_Pisposhis = new Ext.FormPanel({
         region: "center"
         ,frame: true
         ,border: false
         ,labelWidth: 110
         ,labelAlign: "right"
         ,autoScroll: true
         ,monitorValid	: true
         //,disabled: true
         ,bodyStyle: "padding:20px"
         ,items: [
                 {
                         xtype: "hidden"
                         ,id: "id"
                 }
                 ,{
                         xtype: "hidden"
                         ,id: "historder"
                 }
                 ,{
                         layout: "column"
                         ,items: [
                                 {
                                         width: 1000
                                         ,layout: "form"
                                         ,items: [
                                             {
                                                     xtype: "textfield"
                                                     ,id: "pisposhis[refcmnd]"
                                                     ,fieldLabel: "คำสั่ง"
                                                     ,anchor: "95%"
                                             }        
                                             ,{
                                                      layout: "column"
                                                      ,items: [
                                                               {
                                                                        width: 500
                                                                        ,layout: "form"
                                                                        ,defaults: {
                                                                                 anchor: "95%"
                                                                        }
                                                                        ,items: [
                                                                                 new Ext.ux.form.PisComboBox({//การเคลื่อนไหว
                                                                                          fieldLabel: 'การเคลื่อนไหว'
                                                                                          ,hiddenName: 'pisposhis[updcode]'
                                                                                          ,id: 'pisposhis[updcode]'
                                                                                          ,width: 250
                                                                                          ,valueField: 'updcode'
                                                                                          ,displayField: 'updname'
                                                                                          ,urlStore: pre_url + '/code/cupdate'
                                                                                          ,fieldStore: ['updcode', 'updname']
                                                                                 })
                                                                                 ,{
                                                                                          xtype: "textfield"
                                                                                          ,id: "pisposhis[posid]"
                                                                                          ,fieldLabel: "เลขที่ตำแหน่ง"
                                                                                 }
                                                                                 ,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                                                                          fieldLabel: "ตำแหน่งสายงาน"
                                                                                          ,hiddenName: 'pisposhis[poscode]'
                                                                                          ,id: 'pisposhis[poscode]'
                                                                                          ,valueField: 'poscode'
                                                                                          ,displayField: 'posname'
                                                                                          ,urlStore: pre_url + '/code/cposition'
                                                                                          ,fieldStore: ['poscode', 'posname']
                                                                                          ,width: 250
                                                                                                                                                                                   
                                                                                 })
                                                                                 ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                                                                          fieldLabel: "ตำแหน่งบริหาร"
                                                                                          ,hiddenName: 'pisposhis[excode]'
                                                                                          ,id: 'pisposhis[excode]'
                                                                                          ,valueField: 'excode'
                                                                                          ,displayField: 'exname'
                                                                                          ,urlStore: pre_url + '/code/cexecutive'
                                                                                          ,fieldStore: ['excode', 'exname']
                                                                                          ,width: 250                                                                                          
                                                                                                                                                                                    
                                                                                 })
                                                                                 ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                                                                          fieldLabel: "ว./ว.ช/ชช."
                                                                                          ,hiddenName: 'pisposhis[ptcode]'
                                                                                          ,id: 'pisposhis[ptcode]'
                                                                                          ,valueField: 'ptcode'
                                                                                          ,displayField: 'ptname'
                                                                                          ,urlStore: pre_url + '/code/cpostype'
                                                                                          ,fieldStore: ['ptcode', 'ptname']
                                                                                          ,width: 250                                                                                          
                                                                                 })
                                                                        ]
                                                               },{
                                                                        width: 500
                                                                        ,layout: "form"
                                                                        ,items: [
                                                                                 {
                                                                                        xtype: "datefield"
                                                                                        ,id: "pisposhis[forcedate]"
                                                                                        ,fieldLabel: "วันที่มีผลบังคับใช้"
                                                                                        ,format: "d/m/Y"
                                                                                 }
                                                                                 ,new Ext.BoxComponent({
                                                                                          autoEl: {
                                                                                                   tag: 'div',
                                                                                                   style: "padding-top:28px"
                                                                                          }
                                                                                 })
                                                                                 ,new Ext.ux.form.PisComboBox({//ระดับ
                                                                                          fieldLabel: "ระดับ"
                                                                                          ,hiddenName: 'pisposhis[c]'
                                                                                          ,id: 'pisposhis[c]'
                                                                                          ,valueField: 'ccode'
                                                                                          ,displayField: 'cname'
                                                                                          ,urlStore: pre_url + '/code/cgrouplevel'
                                                                                          ,fieldStore: ['ccode', 'cname']
                                                                                          ,width: 250                                                                                         
                                                                                 })
                                                                                 ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                                                                          fieldLabel: "ความเชี่ยวชาญ"
                                                                                          ,hiddenName: 'pisposhis[epcode]'
                                                                                          ,id: 'pisposhis[epcode]'
                                                                                          ,valueField: 'epcode'
                                                                                          ,displayField: 'expert'
                                                                                          ,urlStore: pre_url + '/code/cexpert'
                                                                                          ,fieldStore: ['epcode', 'expert']
                                                                                          ,width: 250                                                                                         
                                                                                 })
                                                                        ]
                                                                
                                                              }
                                                      ]
                                              },{
                                                         layout: "column"
                                                         ,items: [
                                                            {
                                                                width: 500
                                                                ,layout: "form"
                                                                ,items: [
                                                                       {
                                                                           xtype: "compositefield"
                                                                           ,fieldLabel: "เงินเดือน"
                                                                           ,items: [
                                                                               {
                                                                                    xtype: "numericfield"
                                                                                    ,id: "pisposhis[salary]" 
                                                                               }
                                                                               ,{
                                                                                    xtype: "displayfield"
                                                                                    ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                                                                    ,value: "ร้อยละที่ได้เลื่อน:"
                                                                                }
                                                                                ,{
                                                                                    xtype: "numberfield"
                                                                                    ,id: "pisposhis[uppercent]" 
                                                                                }
                                                                           ]
                                                                       }
                                                                       ,{
                                                                           xtype: "compositefield"
                                                                           ,fieldLabel: "ค่าตอบแทนพิเศษ"
                                                                           ,items: [
                                                                               {
                                                                                    xtype: "numericfield"
                                                                                    ,id: "pisposhis[upsalary]" 
                                                                               }
                                                                               ,{
                                                                                    xtype: "displayfield"
                                                                                    ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                                                                    ,value: "เงินประจำตำแหน่ง:"
                                                                                }
                                                                                ,{
                                                                                    xtype: "numericfield"
                                                                                    ,id: "pisposhis[posmny]" 
                                                                                }
                                                                           ]
                                                                       }
                                                                       ,{
                                                                            xtype: "numericfield"
                                                                            ,id: "pisposhis[spmny]"
                                                                            ,fieldLabel: "เงิน พ.ส.ร."
                                                                       }
                                                                ]
                                                            }                                                                                       
                                                         ]
                                              }
                                             ,{
                                                      xtype: "compositefield"
                                                      ,fieldLabel: "กระทรวง"
                                                      ,items: [
                                                               new Ext.ux.form.PisComboBox({//กระทรวง
                                                                        hiddenName: 'pisposhis[mcode]'
                                                                        ,id: 'pisposhis[mcode]'
                                                                        ,valueField: 'mcode'
                                                                        ,displayField: 'minname'
                                                                        ,urlStore: pre_url + '/code/cministry'
                                                                        ,fieldStore: ['mcode', 'minname']
                                                                        ,width: 250                                                               
                                                               })
                                                               ,{
                                                                        xtype: "displayfield"
                                                                        ,style: "padding: 4px;text-align: right;"
                                                                        ,width: 100
                                                                        ,value: "กรม:"
                                                               }
                                                               ,new Ext.ux.form.PisComboBox({//กรม
                                                                        hiddenName: 'pisposhis[deptcode]'
                                                                        ,id: 'pisposhis[deptcode]'
                                                                        ,valueField: 'deptcode'
                                                                        ,displayField: 'deptname'
                                                                        ,urlStore: pre_url + '/code/cdept'
                                                                        ,fieldStore: ['deptcode', 'deptname']
                                                                        ,width: 250
                                                               })
                                                      ]
                                             }
                                             ,new Ext.ux.form.PisComboBox({//กอง
                                                      hiddenName: 'pisposhis[dcode]'
                                                      ,id: 'pisposhis[dcode]'
                                                      ,fieldLabel: "กอง"
                                                      ,valueField: 'dcode'
                                                      ,displayField: 'division'
                                                      ,urlStore: pre_url + '/code/cdivision'
                                                      ,fieldStore: ['dcode', 'division']
                                                      ,width: 250
                                             })
                                             ,{
                                                      xtype: "compositefield"
                                                      ,fieldLabel: "หน่วยงาน"
                                                      ,anchor: "100%"
                                                      ,items: [
                                                               {
                                                                        xtype: "numberfield"
                                                                        ,id: "pisposhis[sdcode]"
                                                                        ,width: 80
                                                                        ,enableKeyEvents: true
                                                                        ,listeners: {
                                                                                 specialkey : function( el,e ){
                                                                                          Ext.getCmp("his_subdept_show").setValue("");
                                                                                          if (e.keyCode == e.RETURN  || e.keyCode == e.TAB){
                                                                                                   loadMask.show();
                                                                                                   Ext.Ajax.request({
                                                                                                      url: pre_url + '/code/csubdept_search_all'
                                                                                                      ,params: {
                                                                                                         sdcode: el.getValue()
                                                                                                      }
                                                                                                      ,success: function(response,opts){
                                                                                                         obj = Ext.util.JSON.decode(response.responseText);
                                                                                                         if (obj.totalcount == 0){
                                                                                                            Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                                            Ext.getCmp("pisposhis[sdcode]").setValue("");
                                                                                                            Ext.getCmp("his_subdept_show").setValue("");
                                                                                                         }
                                                                                                         else{
                                                                                                            Ext.getCmp("pisposhis[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                            Ext.getCmp("his_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                                                          if (Ext.getCmp("his_subdept_show").getValue() == ""){
                                                                                                   Ext.getCmp("pisposhis[sdcode]").setValue("");
                                                                                                   Ext.getCmp("his_subdept_show").setValue("");    
                                                                                          }
                                                                                 }
                                                                                 
                                                                        }
                                                               }
                                                               ,{
                                                                        xtype: "textfield"
                                                                        ,id: "his_subdept_show"
                                                                        ,readOnly: true
                                                                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:80%;"
                                                               }
                                                               ,{
                                                                        xtype: "button"
                                                                        ,id: "his_subdept_button"
                                                                        ,text: "..."
                                                                        ,handler: function(){
                                                                                 searchSubdeptAll(Ext.getCmp("pisposhis[sdcode]"),Ext.getCmp("his_subdept_show"));
                                                                        }
                                                               }
                                                      ]
                                             }
                                             ,{
                                                      xtype: "compositefield"
                                                      ,fieldLabel: "ฝ่าย/กลุ่มงาน"
                                                      ,items: [
                                                               new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                                                        hiddenName: 'pisposhis[seccode]'
                                                                        ,id: 'pisposhis[seccode]'
                                                                        ,valueField: 'seccode'
                                                                        ,displayField: 'secname'
                                                                        ,urlStore: pre_url + '/code/csection'
                                                                        ,fieldStore: ['seccode', 'secname']
                                                                        ,width: 250
                                                                        
                                                               })
                                                               ,{
                                                                        xtype: "displayfield"
                                                                        ,style: "padding: 4px;text-align: right;"
                                                                        ,width: 100
                                                                        ,value: "งาน:"
                                                               }
                                                               ,new Ext.ux.form.PisComboBox({//งาน
                                                                        hiddenName: 'pisposhis[jobcode]'
                                                                        ,id: 'pisposhis[jobcode]'
                                                                        ,valueField: 'jobcode'
                                                                        ,displayField: 'jobname'
                                                                        ,urlStore: pre_url + '/code/cjob'
                                                                        ,fieldStore: ['jobcode', 'jobname']
                                                                        ,width: 250
                                                               })
                                                      ]
                                             } 
                                             ,{
                                                         xtype: "textfield"
                                                         ,id: "pisposhis[note]"
                                                         ,fieldLabel: "หมายเหตุ"
                                                         ,anchor: "100%"
                                             }
                                         ]
                                 }	
                         ]
                 }
         ]
         ,buttons: [
                  { 
                          text:'บันทึก'
                          ,formBind: true 
                          ,handler:function(){ 		
                                  formDatailData_Pisposhis.getForm().submit(
                                  { 
                                          method:'POST'
                                          ,url: his_url
                                          ,waitTitle:'Saving Data'
                                          ,waitMsg:'Sending data...'
                                          ,success:function(){		
                                                  Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                  if (btn == 'ok')
                                                                  {
                                                                          formDatailData_Pisposhis.getForm().reset();
                                                                          formDatailData_Pisposhis.disable();
                                                                          detail_pisposhisGridStore.reload();
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
                                                          
                                                          Ext.Msg.alert('สถานะ', 'Authentication server is unreachable : ' + action.response.responseText); 
                                                  } 
                                          } 
                                  }); 
                          } 
                  },{
                           text: "ยกเลิก"
                           ,handler	: function(){
                                    formDatailData_Pisposhis.getForm().reset();
                                    formDatailData_Pisposhis.disable();
                                    data_pisposhisGridStore.load({ params: { start: 0, limit: 20} });	
                           }
                  }	
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         }
});

/*******************************************************************/
/*Panel*/
/*******************************************************************/
var panelPosHisFirst = new Ext.Panel({
         layout: "border"
         ,items: [
                  data_pisposhisGrid
         ]
});

var panelPosHisSecond = new Ext.Panel({
         layout: "border"
         ,items: [
                 detail_pisposhisGrid
                 ,formDatailData_Pisposhis
         ]
});

var panelPosHis = new Ext.Panel({
         layout: "card"
         ,activeItem: 0
         ,items: [
                  panelPosHisFirst
                  ,panelPosHisSecond
         ]
});
/********************************************************************/
/*Function*/
/******************************************************************/
function searchEditDataPisposhis(id,historder){
         loadMask.show();
         Ext.Ajax.request({
                 url: pre_url + '/info_pisposhis/search_edit'
                 ,params: {
                         id: id
                         ,historder: historder
                 }
                 ,success: function(response, opts) {
                           var obj = Ext.decode(response.responseText);
                           data = obj.data.pisposhis;
                           if (obj.success){
                                    formDatailData_Pisposhis.enable();
                                    formDatailData_Pisposhis.getForm().reset();
                                    //setReadOnlyWorkPlace();
                                    Ext.getCmp("pisposhis[note]").setValue(data.note);
                                    Ext.getCmp("pisposhis[refcmnd]").setValue(data.refcmnd);
                                    Ext.getCmp("pisposhis[posid]").setValue(data.posid);
                                    Ext.getCmp("pisposhis[salary]").setValue(data.salary);
                                    
                                    Ext.getCmp("pisposhis[uppercent]").setValue(data.uppercent);
                                    Ext.getCmp("pisposhis[upsalary]").setValue(data.upsalary);
                                    Ext.getCmp("pisposhis[posmny]").setValue(data.posmny);
                                    Ext.getCmp("pisposhis[spmny]").setValue(data.spmny);
                                    
                                    Ext.getCmp("id").setValue(data.id[0]);
                                    Ext.getCmp("historder").setValue(data.historder);
                                    Ext.getCmp("his_subdept_show").setValue(data.his_subdept_show);
                                    Ext.getCmp("pisposhis[sdcode]").setValue(data.sdcode);
                                    Ext.getCmp("pisposhis[forcedate]").setValue(to_date_app(data.forcedate));
                                    Ext.getCmp("pisposhis[updcode]").getStore().load({
                                             params: {
                                                      updcode: data.updcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[updcode]").setValue(data.updcode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[poscode]").getStore().load({
                                             params: {
                                                      poscode: data.poscode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[poscode]").setValue(data.poscode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[excode]").getStore().load({
                                             params: {
                                                      excode: data.excode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[excode]").setValue(data.excode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[ptcode]").getStore().load({
                                             params: {
                                                      ptcode: data.ptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[ptcode]").setValue(data.ptcode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[c]").getStore().load({
                                             params: {
                                                      ccode: data.c
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[c]").setValue(data.c);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[epcode]").getStore().load({
                                             params: {
                                                      epcode: data.epcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[epcode]").setValue(data.epcode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[mcode]").getStore().load({
                                             params: {
                                                      mcode: data.mcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[mcode]").setValue(data.mcode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[deptcode]").getStore().load({
                                             params: {
                                                      deptcode: data.deptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[deptcode]").setValue(data.deptcode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[dcode]").getStore().load({
                                             params: {
                                                      dcode: data.dcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[dcode]").setValue(data.dcode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[seccode]").getStore().load({
                                             params: {
                                                      seccode: data.seccode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[seccode]").setValue(data.seccode);
                                             }
                                    });
                                    Ext.getCmp("pisposhis[jobcode]").getStore().load({
                                             params: {
                                                      jobcode: data.jobcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisposhis[jobcode]").setValue(data.jobcode);
                                                      loadMask.hide();
                                             }
                                    });
                           }
                           else{
                                    Ext.Msg.alert("สถานะ","กรุณาลองใหม่อีกครั้ง");
                                    loadMask.hide();
                           }
                         
                 }
                 ,failure: function(response, opts) {
                         Ext.Msg.alert("สถานะ", response.statusText);
                         loadMask.hide();
                 }
         });
}

function delete_detail_pisposhis(id){
        
        Ext.Msg.confirm('สถานะ', 'ต้องการลบใช่หรือไม่', function(btn, text){			
                if (btn == 'yes')
                {				
                        loadMask.show();
                        Ext.Ajax.request({
                                url: 'data_pisposhis/delete' , 
                                params	: { 
                                        id	: id
                                        ,random: Math.random()
                                },	
                                failure: function ( result, request) { 
                                        loadMask.hide();
                                        Ext.MessageBox.alert('สถานะ', "Error : "+result.responseText); 
                                },
                                success: function ( result, request ) { 
                                        loadMask.hide();
                                        var obj = Ext.util.JSON.decode(result.responseText); 
                                        if (obj.success == true)
                                        {
                                                Ext.MessageBox.alert('สถานะ', 'ลบเสร็จเรียบร้อย',function(btn, text){
                                                                if (btn == 'ok'){
                                                                        detail_pisposhisGridStore.reload();
                                                                }
                                                        }
                                                ); 
                                        }
                                }
                        });	
                }//end if (btn == 'yes')
                else
                {
                        return false;
                }
        });		
}



