work_place = {
         mcode: "pispersonel[mincode]"
         ,deptcode: "pispersonel[deptcode]"
         ,dcode: "pispersonel[dcode]"
         ,sdcode: "pispersonel[sdcode]"
         ,sdcode_show: "now_subdept_show"
         ,sdcode_button: "now_subdept_button"
         ,seccode: "pispersonel[seccode]"
         ,jobcode: "pispersonel[jobcode]"
}
/********************************************************************/
/*Grid*/
/******************************************************************/    
var perform_personSearch = new Ext.ux.grid.Search({
         iconCls: 'search'
         ,minChars: 3
         ,autoFocus: true
         ,position: "top"
         ,width: 200
});
var perform_personFields = [
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
    
var perform_personCols = [
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
    
var perform_personGridStore = new Ext.data.JsonStore({
        url: pre_url + "/info_personal/read"
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: perform_personFields
        ,idProperty: 'id'
});
    
var perform_personGrid = new Ext.grid.GridPanel({
        region: 'center'
        ,split: true
        ,store: perform_personGridStore
        ,columns: perform_personCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
        ,plugins: [perform_personSearch]
        ,bbar: new Ext.PagingToolbar({
                  pageSize: 20
                  ,autoWidth: true
                  ,store: perform_personGridStore
                  ,displayInfo: true
                  ,displayMsg	: 'Displaying {0} - {1} of {2}'
                  ,emptyMsg: "Not found"
        })
        ,tbar: []
});
    
perform_personGrid.on('rowdblclick', function(grid, rowIndex, e ) {
         data_select = grid.getSelectionModel().getSelected().data;
         data_personel_id = data_select.id;
         searchEditPerformPerson(data_select);         
});
function searchEditPerformPerson(data_select){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_perform_now/search_edit"
                  ,params: {
                           id: data_select.id
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           data = obj.data.pispersonel;
                           if (obj.success){
                                    tab_personel.getActiveTab().setTitle("ปฏิบัติราชการปัจจุบัน ( " +data_select.name+ " )")
                                    panelPerformPersonnow.getLayout().setActiveItem(perform_person_now_form);
                                    perform_person_now_form.getForm().reset();
                                    if (type_group_user == "1"){
                                     setReadOnlyWorkPlace();
                                    }
                                    if(data.kbk == "1"){
                                             Ext.getCmp("kbk1").setValue(data.kbk);       
                                    }
                                    else if(data.kbk == "0"){
                                             Ext.getCmp("kbk2").setValue(data.kbk);       
                                    }                                    
                                    Ext.getCmp("pispersonel[specialty]").setValue(data.specialty);
                                    Ext.getCmp("pispersonel[spmny]").setValue(data.spmny);
                                    Ext.getCmp("pispersonel[spmny1]").setValue(data.spmny1);
                                    Ext.getCmp("pispersonel[spmny2]").setValue(data.spmny2);
                                    Ext.getCmp("pispersonel[note]").setValue(data.note);
                                    Ext.getCmp("pispersonel[note2]").setValue(data.note2);
                                    Ext.getCmp("pispersonel[sdcode]").setValue(data.sdcode);
                                    Ext.getCmp("id").setValue(data.id);
                                    Ext.getCmp("now_subdept_show").setValue(data.now_subdept_show);
                                    Ext.getCmp("posnamej18").setValue(data.posnamej18);
                                    Ext.getCmp("posnamenow").setValue(data.posnamenow);
                                    Ext.getCmp("salarynow").setValue(data.salarynow);
                                    Ext.getCmp("salaryj18").setValue(data.salaryj18);
                                    Ext.getCmp("sdnamej18").setValue(data.sdnamej18);
                                    Ext.getCmp("pispersonel[birthdate]").setValue(to_date_app(data.birthdate));
                                    Ext.getCmp("pispersonel[retiredate]").setValue(to_date_app(data.retiredate));
                                    Ext.getCmp("pispersonel[appointdate]").setValue(to_date_app(data.appointdate));
                                    Ext.getCmp("pispersonel[deptdate]").setValue(to_date_app(data.deptdate));
                                    Ext.getCmp("pispersonel[attenddate]").setValue(to_date_app(data.attenddate));
                                    Ext.getCmp("pispersonel[cdate]").setValue(to_date_app(data.cdate));
                                    Ext.getCmp("pispersonel[getindate]").setValue(to_date_app(data.getindate));
                                    Ext.getCmp("pispersonel[reentrydate]").setValue(to_date_app(data.reentrydate));
                                    Ext.getCmp("pispersonel[quitdate]").setValue(to_date_app(data.quitdate));
                                    Ext.getCmp("pispersonel[j18code]").getStore().load({
                                             params: {
                                                      j18code: data.j18code
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[j18code]").setValue(data.j18code);
                                             }
                                    });                                    
                                    Ext.getCmp("pispersonel[mincode]").getStore().load({
                                             params: {
                                                      mcode: data.mincode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[mincode]").setValue(data.mincode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[deptcode]").getStore().load({
                                             params: {
                                                      deptcode: data.deptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[deptcode]").setValue(data.deptcode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[dcode]").getStore().load({
                                             params: {
                                                      dcode: data.dcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[dcode]").setValue(data.dcode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[seccode]").getStore().load({
                                             params: {
                                                      seccode: data.seccode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[seccode]").setValue(data.seccode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[jobcode]").getStore().load({
                                             params: {
                                                      jobcode: data.jobcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[jobcode]").setValue(data.jobcode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[spexpos]").getStore().load({
                                             params: {
                                                      spexpos: data.spexpos
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[spexpos]").setValue(data.spexpos);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[qcode]").getStore().load({
                                             params: {
                                                      qcode: data.qcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[qcode]").setValue(data.qcode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[macode]").getStore().load({
                                             params: {
                                                      macode: data.macode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[macode]").setValue(data.macode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[codetrade]").getStore().load({
                                             params: {
                                                      codetrade: data.codetrade
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[codetrade]").setValue(data.codetrade);
                                                      loadMask.hide();
                                             }
                                    });
                                    SetAgePerformPersonGov();
                           }
                           else{
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
function searchPerformPersonById(personel_id){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_personal/search_id"
                  ,params: {
                           id: personel_id
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           if (obj.data.length != 0){
                                    searchEditPerformPerson(obj.data[0]);                                    
                           }
                           else{
                                    data_personel_id = "";
                                    panelPerformPersonnow.getLayout().setActiveItem(panelPerformPersonnowFirst);
                                    loadMask.hide();
                           }
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
perform_person_now_form = new Ext.form.FormPanel({
        frame: true
        ,bodyStyle: "padding:20px"
        ,monitorValid: true
        ,labelAlign: "right"
        ,autoScroll: true
        ,items: [
                  {
                           xtype: "hidden"
                           ,id: "id"
                  }
                  ,{//วันที่เกษียณ
                           xtype: "hidden"
                           ,id: "pispersonel[retiredate]"
                  }
                  ,{
                           xtype: "compositefield"
                           ,fieldLabel: "ปฏิบัติงานจริง"
                           ,items: [
                                    new Ext.ux.form.PisComboBox({
                                             id: 'pispersonel[j18code]'
                                             ,hiddenName:'pispersonel[j18code]'
                                             ,valueField: 'j18code'
                                             ,displayField: 'j18status'
                                             ,urlStore: pre_url + '/code/cj18status'
                                             ,fieldStore: ['j18code', 'j18status']
                                             ,width: 200
                                    })
                                    ,{
                                             xtype: "displayfield"
                                             ,style: "padding: 4px;text-align: right;"
                                             ,width: 150
                                             ,value: "รักษาการในตำแหน่ง:"
                                    }
                                    ,new Ext.ux.form.PisComboBox({
                                             id: 'pispersonel[spexpos]'
                                             ,hiddenName:'pispersonel[spexpos]'
                                             ,valueField: 'excode'
                                             ,displayField: 'exname'
                                             ,urlStore: pre_url + '/code/cexecutive'
                                             ,fieldStore: ['excode', 'exname']
                                             ,width: 300
                                    })
                           ]
                  }
                  ,{
                           xtype: "fieldset"
                           ,bodyStyle: "padding:10px"
                           ,width: 1000
                           ,layout: "form"  
                           ,title: "หน่วยงานปฏิบัติงานจริง"
                           ,items: [
                                    {
                                             xtype: "compositefield"
                                             ,fieldLabel: "ตำแหน่ง"
                                             ,items: [
                                                      {
                                                               xtype: "textfield"
                                                               ,id: "posnamenow"
                                                               ,width: 350
                                                               ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                                               ,readOnly: true
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align: right;"
                                                               ,width: 100
                                                               ,value: "เงินเดือน:"
                                                      }
                                                      ,{
                                                               xtype: "textfield"
                                                               ,id: "salarynow"
                                                               ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                                               ,readOnly: true
                                                      }
                                             ]
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "กระทรวง"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//กระทรวง
                                                               hiddenName: 'pispersonel[mincode]'
                                                               ,id: 'pispersonel[mincode]'
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
                                                               hiddenName: 'pispersonel[deptcode]'
                                                               ,id: 'pispersonel[deptcode]'
                                                               ,valueField: 'deptcode'
                                                               ,displayField: 'deptname'
                                                               ,urlStore: pre_url + '/code/cdept'
                                                               ,fieldStore: ['deptcode', 'deptname']
                                                               ,width: 250
                                                      })
                                             ]
                                    }
                                    ,new Ext.ux.form.PisComboBox({//กอง
                                             hiddenName: 'pispersonel[dcode]'
                                             ,id: 'pispersonel[dcode]'
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
                                                               ,id: "pispersonel[sdcode]"
                                                               ,width: 80
                                                               ,enableKeyEvents: (user_work_place.sdcode == undefined)? true : false
                                                               ,listeners: {
                                                                        keydown : function( el,e ){
                                                                                 Ext.getCmp("now_subdept_show").setValue("");
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
                                                                                                   Ext.getCmp("pispersonel[sdcode]").setValue("");
                                                                                                   Ext.getCmp("now_subdept_show").setValue("");
                                                                                                }
                                                                                                else{
                                                                                                   Ext.getCmp("pispersonel[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                   Ext.getCmp("now_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                                                 if (Ext.getCmp("now_subdept_show").getValue() == ""){
                                                                                          Ext.getCmp("pispersonel[sdcode]").setValue("");
                                                                                          Ext.getCmp("now_subdept_show").setValue("");    
                                                                                 }
                                                                        }
                                                                        
                                                               }
                                                      }
                                                      ,{
                                                               xtype: "textfield"
                                                               ,id: "now_subdept_show"
                                                               ,readOnly: true
                                                               ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:80%;"
                                                      }
                                                      ,{
                                                               xtype: "button"
                                                               ,id: "now_subdept_button"
                                                               ,text: "..."
                                                               ,handler: function(){
                                                                        searchSubdept(Ext.getCmp("pispersonel[sdcode]"),Ext.getCmp("now_subdept_show"));
                                                               }
                                                      }
                                             ]
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "ฝ่าย/กลุ่มงาน"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                                               hiddenName: 'pispersonel[seccode]'
                                                               ,id: 'pispersonel[seccode]'
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
                                                               hiddenName: 'pispersonel[jobcode]'
                                                               ,id: 'pispersonel[jobcode]'
                                                               ,valueField: 'jobcode'
                                                               ,displayField: 'jobname'
                                                               ,urlStore: pre_url + '/code/cjob'
                                                               ,fieldStore: ['jobcode', 'jobname']
                                                               ,width: 250
                                                      })
                                             ]
                                    }
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           } 
                  }
                  ,{
                           xtype: "fieldset"
                           ,bodyStyle: "padding:10px"
                           ,width: 1000
                           ,layout: "form"
                           ,title: "ตำแหน่งปัจจุบันตาม จ.18"
                           ,items: [
                                    {
                                             layout: "column"
                                             ,items: [
                                                      {
                                                            columnWidth: .7
                                                            ,layout: "form"
                                                            ,items : [
                                                                        {
                                                                                 xtype: "textfield"
                                                                                 ,fieldLabel: "ตำแหน่ง"
                                                                                 ,anchor: "100%"
                                                                                 ,id: "posnamej18"
                                                                                 ,readOnly: true
                                                                        }                                
                                                              ]
                                                      }
                                                      ,{
                                                               columnWidth: .3
                                                               ,layout: "form"
                                                               ,items : [
                                                                        {
                                                                                 xtype: "numberfield"
                                                                                 ,anchor: "100%"
                                                                                 ,fieldLabel: "เงินเดือน"
                                                                                 ,id: "salaryj18"
                                                                                 ,readOnly: true
                                                                        }
                                                               ]
                                                      }

                                             ]
                                    }
                                    ,{
                                             xtype: "textarea"
                                             ,fieldLabel: "หน่วยงาน"
                                             ,anchor: "100%"
                                             ,id: "sdnamej18"
                                             ,readOnly: true
                                    }
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           } 
                  }
                  ,{
                           layout: "column"
                           ,width: 1000
                           ,items:[
                                    {
                                             columnWidth: .3
                                             ,layout: "form"
                                             ,labelWidth: 150
                                             ,defaults : {
                                                     anchor: "100%"
                                             }
                                             ,items : [
                                                      {//วันเกิด
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันเกิด"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[birthdate]"
                                                               ,listeners: {
                                                                        select: function(el,date ){
                                                                                 SetAgePerformPersonGov();											
                                                                        } 
                                                               }
                                                      }
                                                     ,{//วันบรรจุเข้ารับราชการ
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันบรรจุเข้ารับราชการ"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[appointdate]"
                                                               ,listeners: {
                                                                        select: function(el,date ){
                                                                                 SetAgePerformPersonGov();											
                                                                        } 
                                                               }
                                                     }
                                                     ,{//วันเข้าสู่หน่วยงานปัจจุบัน
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันเข้าสู่หน่วยงานปัจจุบัน"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[deptdate]"
                                                               ,listeners: {
                                                                        select: function(el,date ){
                                                                                 SetAgePerformPersonGov();											
                                                                        } 
                                                               }
                                                     }
                                                     ,{//วันที่เข้าสู่ระดับปัจจุบัน
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันที่เข้าสู่ระดับปัจจุบัน"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[cdate]"
                                                               ,listeners: {
                                                                        select: function(el,date ){
                                                                                 SetAgePerformPersonGov();											
                                                                        } 
                                                               }
                                                      }
                                                      ,{//วันที่มาช่วยราชการ
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันที่มาช่วยราชการ"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[attenddate]"
                                                               ,listeners: {
                                                                        select: function(el,date ){
                                                                                 SetAgePerformPersonGov();											
                                                                        } 
                                                               }
                                                      } 
                                             ]
                                    }
                                    ,{
                                             columnWidth: .4
                                             ,bodyStyle: "padding:0 10px 0 10px"
                                             ,items : [
                                                      new Ext.BoxComponent({
                                                               autoEl: {
                                                                        tag: "div"
                                                                        ,id: "temp_etc1"
                                                                        ,html: "<table style='font:12px tahoma,arial,helvetica,sans-serif'>" +
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px'>อายุ:</td><td></td></tr>" +                                          
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px'>อายุราชการ:</td><td></td></tr>" +
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px'>ระยะเวลา:</td><td></td></tr>" +
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px'>ระยะเวลา:</td><td></td></tr>" +
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px'>ระยะเวลา:</td><td></td></tr>" +
                                                                        "</table>"
                                                               }
                                                      })
                                             ]
                                    }
                                    ,{
                                             columnWidth: .3
                                             ,layout: "form"
                                             ,labelWidth: 140
                                             ,defaults : {
                                                     anchor: "100%"
                                             }
                                             ,items : [
                                                      new Ext.BoxComponent({
                                                               autoEl: {
                                                                        tag: "div"
                                                                        ,id: "temp_etc2"
                                                                        ,html: "<table style='font:12px tahoma,arial,helvetica,sans-serif'>" +
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px' width='140px'>วันที่ครบเกษียณ:</td><td></td></tr>" +                                          
                                                                                 "<tr ><td style='padding-bottom:4px' align='right' height='24px' width='140px'>ระยะครบเกบียณ:</td><td></td></tr>" +
                                                                        "</table>" 
                                                               }
                                                      })
                                                      ,{//วันที่รับโอน
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันที่รับโอน"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[getindate]"
                                                      }
                                                      ,{//วันที่บรรจุกลับ
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันที่บรรจุกลับ"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[reentrydate]"
                                                      }
                                                      ,{//วันที่ออกจากราชการ
                                                               xtype: "datefield"
                                                               ,fieldLabel: "วันที่ออกจากราชการ"
                                                               ,format: "d/m/Y"
                                                               ,id: "pispersonel[quitdate]"
                                                      }
                                             ]
                                }
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           }
                  }
                  ,{
                           xtype: "compositefield"
                           ,fieldLabel: "วุฒิในตำแหน่ง"
                           ,items: [
                                    new Ext.ux.form.PisComboBox({
                                             id: 'pispersonel[qcode]'
                                             ,hiddenName:'pispersonel[qcode]'
                                             ,valueField: 'qcode'
                                             ,displayField: 'qualify'
                                             ,urlStore: pre_url + '/code/cqualify'
                                             ,fieldStore: ['qcode', 'qualify']
                                             ,width: 400
                                    })
                                    ,{
                                             xtype: "displayfield"
                                             ,style: "padding: 4px;text-align: right;"
                                             ,width: 70
                                             ,value: "วิชาเอก:"
                                    }
                                    ,new Ext.ux.form.PisComboBox({
                                             id: 'pispersonel[macode]'
                                             ,hiddenName:'pispersonel[macode]'
                                             ,valueField: 'macode'
                                             ,displayField: 'major'
                                             ,urlStore: pre_url + '/code/cmajor'
                                             ,fieldStore: ['macode', 'major']
                                             ,width: 415
                                    })                                    
                           ]
                  }
                  ,new Ext.ux.form.PisComboBox({
                           fieldLabel: "ใบอนุญาตประกอบอาชีพ"
                           ,id: 'pispersonel[codetrade]'
                           ,hiddenName:'pispersonel[codetrade]'
                           ,valueField: 'codetrade'
                           ,displayField: 'trade'
                           ,urlStore: pre_url + '/code/ctrade'
                           ,fieldStore: ['codetrade', 'trade']
                           ,width: 895
                  })                  
                  ,{
                           layout: "column"
                           ,items: [
                                    {
                                             width : 300
                                             ,layout: "form"
                                             ,items: [
                                                      {
                                                               xtype: 'radiogroup',
                                                               fieldLabel: 'สมาชิก กบข.',
                                                               columns: 2,
                                                               items: [
                                                                        {boxLabel: 'สมัคร', name: 'kbk',id: "kbk1", inputValue: 1},
                                                                        {boxLabel: 'ไม่สมัคร', name: 'kbk',id: "kbk2", inputValue: 0}
                                                               ]
                                                      }
                                             ]
                                    }
                                    ,{
                                             width : 700
                                             ,layout: "form"
                                             ,defaults: {
                                                      anchor: "100%"
                                             }
                                             ,items: [
                                                      {
                                                               xtype: "textfield"
                                                               ,fieldLabel: "ความสามารถพิเศษ"
                                                               ,id: "pispersonel[specialty]"
                                                      }
                                             ]
                                    }
                                    
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           }
                  }
                  ,{
                           xtype: "compositefield"
                           ,fieldLabel: "พสร."
                           ,items: [
                                    {
                                             xtype: "numberfield"
                                             ,id: "pispersonel[spmny]"
                                    }
                                    ,{
                                             xtype: "displayfield"
                                             ,style: "padding: 4px;text-align: right;"
                                             ,width: 150
                                             ,value: "พภม.:"
                                    }
                                    ,{
                                             xtype: "numberfield"
                                             ,id: "pispersonel[spmny1]"
                                    }
                                    ,{
                                             xtype: "displayfield"
                                             ,style: "padding: 4px;text-align: right;"
                                             ,width: 150
                                             ,value: "พอส.:"
                                    }
                                    ,{
                                             xtype: "numberfield"
                                             ,id: "pispersonel[spmny2]"
                                    }
                           ]
                  }
                  ,{
                           xtype: "textfield"
                           ,fieldLabel: "หมายเหตุ1"
                           ,width: 895
                           ,id: "pispersonel[note]"
                  }
                  ,{
                           xtype: "textfield"
                           ,fieldLabel: "หมายเหตุ2"
                           ,width: 895
                           ,id: "pispersonel[note2]"
                  }
         ]
        ,buttons: [
                  { 
                           text:'บันทึก'
                           ,formBind: true 
                           ,handler:function(){ 					
                                    perform_person_now_form.getForm().submit({ 
                                             method:'POST'
                                             ,url: pre_url + "/info_perform_now/edit"
                                             ,waitTitle:'Saving Data'
                                             ,waitMsg:'Sending data...'
                                             ,success:function(){		
                                                      Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                               if (btn == 'ok'){
                                                                        tab_personel.getActiveTab().setTitle("ปฏิบัติราชการปัจจุบัน");
                                                                        data_personel_id = "";
                                                                        panelPerformPersonnow.getLayout().setActiveItem(panelPerformPersonnowFirst);
                                                                        perform_personGridStore.reload();
                                                               }	
                                                      });                                     
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
                  }
                  ,{
                           text: "ยกเลิก"
                           ,handler: function(){
                                    tab_personel.getActiveTab().setTitle("ปฏิบัติราชการปัจจุบัน");
                                    data_personel_id = "";
                                    panelPerformPersonnow.getLayout().setActiveItem(panelPerformPersonnowFirst);
                                    perform_personGridStore.reload();
                           }
                  }	
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         }
});


/***********************************************************************/
//panel perform person now
/************************************************************************/
var panelPerformPersonnowFirst = new Ext.Panel({
         layout: "border"
         ,items: [
                 perform_personGrid
         ]
});
var panelPerformPersonnow = new Ext.Panel({
         layout: "card"
         //,activeItem: 0
         ,layoutConfig: {
                  deferredRender: true
                  ,layoutOnCardChange: true
         }
         ,items: [
                  panelPerformPersonnowFirst
                  ,perform_person_now_form
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         }
});

/********************************************************************/
/*FUNCTION*/
/******************************************************************/ 
function SetAgePerformPersonGov(){
        var data = {
                age: ''
                ,age_gov:''
                ,term_task:''
                ,period1:''
                ,period2:""
        };
        if (Ext.getCmp("pispersonel[birthdate]").getRawValue() != ""){
                  dt = new Date();
                  birthdate = Ext.getCmp("pispersonel[birthdate]").getValue();
                  age =  dateDiff(new Date(),birthdate)
                  data.age = age[0]+" ปี  " + age[1] + " เดือน  " + age[2] + " วัน" ;
                  if ( birthdate.getMonth() >= 9 ){
                           if (birthdate.getMonth() == 9 && birthdate.getDate() == 1){
                                    date_retire = new Date(birthdate.getFullYear()+60,8,30);      
                           }
                           else{
                                    date_retire = new Date(birthdate.getFullYear()+61,8,30);     
                           }
                  }
                  else{
                           date_retire = new Date(birthdate.getFullYear()+60,8,30); 
                  }
                  if (new Date() > date_retire){
                           duration_retire = dateDiff(new Date(),date_retire);
                           date_retire.setDate(date_retire.getDate() - 1 );
                  }
                  else{
                           duration_retire = dateDiff(date_retire,new Date());
                           date_retire.setDate(date_retire.getDate() - 1 );
                  }
                  
                  duration_retire = duration_retire[0]+" ปี  " + duration_retire[1] + " เดือน  " + duration_retire[2] + " วัน" ;
                  date_retire = pad2(date_retire.getDate()) + "/" + pad2(date_retire.getMonth()+1) + "/" + (date_retire.getFullYear() + 543);
                  data2 = {
                          date_retire: date_retire
                          ,term_retire: duration_retire
                  };
                  var tpl2 = new Ext.Template(
                      "<table style='font:12px tahoma,arial,helvetica,sans-serif'>" ,
                       "<tr ><td style='padding-bottom:4px' align='right' height='24px' width='140px'>วันที่ครบเกษียณ:</td><td>{date_retire}</td></tr>" ,
                       "<tr ><td style='padding-bottom:4px' align='right' height='24px' width='140px'>ระยะครบเกบียณ:</td><td>{term_retire}</td></tr>" ,
                       "</table>" 
                  );
                  tpl2.overwrite(Ext.get("temp_etc2"), data2);
                  Ext.getCmp("pispersonel[retiredate]").setValue(date_retire);									 
        }

        if (Ext.getCmp("pispersonel[appointdate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[appointdate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.age_gov = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
        }

        if (Ext.getCmp("pispersonel[deptdate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[deptdate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.term_task = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
        }

        if (Ext.getCmp("pispersonel[cdate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[cdate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.period1 = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
        }
        
         if (Ext.getCmp("pispersonel[attenddate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[attenddate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.period2 = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
         }
        
        var tpl = new Ext.Template(
                "<table style='font:12px tahoma,arial,helvetica,sans-serif'>" ,
                          "<tr ><td style='padding-bottom:4px' align='right' height='24px'>อายุ:</td><td>{age}</td></tr>" ,
                          "<tr ><td style='padding-bottom:4px' align='right' height='24px'>อายุราชการ:</td><td>{age_gov}</td></tr>" ,
                          "<tr ><td style='padding-bottom:4px' align='right' height='24px'>ระยะเวลา:</td><td>{term_task}</td></tr>" ,
                          "<tr ><td style='padding-bottom:4px' align='right' height='24px'>ระยะเวลา:</td><td>{period1}</td></tr>" ,
                          "<tr ><td style='padding-bottom:4px' align='right' height='24px'>ระยะเวลา:</td><td>{period2}</td></tr>" ,
                  "</table>"
        );
        tpl.overwrite(Ext.get("temp_etc1"), data);
}