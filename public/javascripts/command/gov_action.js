//-------------------------------------
// Form Center
//-------------------------------------
var govActionForm = new Ext.FormPanel({
    labelWidth: 100
    ,autoScroll: true
    ,url: pre_url + '/gov_action/process_gov_action'
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
                    xtype: "fieldset"
                    ,items: [
                        {
                            xtype: "compositefield"
                            ,fieldLabel: "เลขที่ตำแหน่ง"
                            ,anchor: "100%"
                            ,items: [
                                {
                                    xtype: "numberfield"
                                    ,id: "pispersonel[posid]"
                                    ,width: 100
                                    ,enableKeyEvents: true
                                    ,allowBlank: false
                                    ,listeners: {
                                        focus: function(el){
                                            posid = el.getValue();
                                            Ext.getCmp("gov_name").setValue("");
                                            govActionReset();
                                            el.setValue(posid);
                                        }
                                        ,specialkey : function( el,e ){
                                            if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                loadMask.show();
                                                Ext.Ajax.request({
                                                    url: pre_url + '/info_personal/search_posid'
                                                    ,params: {
                                                        posid: el.getValue()
                                                    }
                                                    ,success: function(response,opts){
                                                        obj = Ext.util.JSON.decode(response.responseText);
                                                        if (obj.success){
                                                            Ext.getCmp("pispersonel[id]").setValue(obj.data[0].id);
                                                            Ext.getCmp("gov_name").setValue(obj.data[0].name);
                                                            Ext.getCmp("pispersonel[posid]").setValue(obj.data[0].posid);
                                                            govActionSearchEdit(obj.data[0].id);
                                                        }
                                                        else{
                                                            Ext.getCmp("pispersonel[id]").setValue("");
                                                            Ext.getCmp("gov_name").setValue("");
                                                            Ext.getCmp("pispersonel[posid]").setValue("");
                                                            govActionReset();
                                                            Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                            loadMask.hide();
                                                        }
                                                        
                                                    }
                                                    ,failure: function(response,opts){
                                                        Ext.Msg.alert("สถานะ",response.statusText);
                                                        loadMask.hide();
                                                    }
                                                });                                                                                           
                                            }        
                                        }
                                        ,blur: function(el){
                                            if (Ext.getCmp("gov_name").getValue() == ""){
                                               Ext.getCmp("pispersonel[id]").setValue("");
                                               Ext.getCmp("gov_name").setValue("");
                                               Ext.getCmp("pispersonel[posid]").setValue("");
                                            }
                                        }
                                    }
                                }
                                ,{
                                    xtype: "button"
                                    ,text: "..."
                                    ,handler: function(){
                                        personelGovAction(Ext.getCmp("pispersonel[posid]"),Ext.getCmp("gov_name"),Ext.getCmp("pispersonel[id]"));
                                    }
                                }                                
                                ,{
                                    xtype: "hidden"
                                    ,id:  "pispersonel[id]"
                                    ,allowBlank: false
                                }
                            ]
                        }
                        ,{
                            xtype: "textfield"
                            ,id: "gov_name"
                            ,readOnly: true
                            ,fieldLabel: "ชื่อ-นามสกุล"
                            ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                        }
                        ,new Ext.ux.form.PisComboBox({
                            fieldLabel: "ปฏิบัติงานตรง จ.18"
                            ,id: 'pispersonel[j18code]'
                            ,hiddenName:'pispersonel[j18code]'
                            ,valueField: 'j18code'
                            ,displayField: 'j18status'
                            ,urlStore: pre_url + '/code/cj18status'
                            ,fieldStore: ['j18code', 'j18status']
                            ,width: 350
                        })
                        ,{
                            layout: "column"
                            ,items: [
                                {
                                    width: 480
                                    ,layout: "form"
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                            fieldLabel: "ตำแหน่งสายงาน"
                                            ,hiddenName: 'pispersonel[poscode]'
                                            ,id: 'pispersonel[poscode]'
                                            ,valueField: 'poscode'
                                            ,displayField: 'posname'
                                            ,urlStore: pre_url + '/code/cposition'
                                            ,fieldStore: ['poscode', 'posname']
                                            ,anchor: "95%"
                                        })
                                        ,{
                                            xtype: "numericfield"
                                            ,id: "pispersonel[salary]"
                                            ,fieldLabel: "เงินเดือน"
                                            
                                        }
                                        ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                            fieldLabel: "ตำแหน่งบริหาร"
                                            ,hiddenName: 'pispersonel[excode]'
                                            ,id: 'pispersonel[excode]'
                                            ,valueField: 'excode'
                                            ,displayField: 'exname'
                                            ,urlStore: pre_url + '/code/cexecutive'
                                            ,fieldStore: ['excode', 'exname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กระทรวง
                                            fieldLabel: "กระทรวง"
                                            ,hiddenName: 'pispersonel[mincode]'
                                            ,id: 'pispersonel[mincode]'
                                            ,valueField: 'mcode'
                                            ,displayField: 'minname'
                                            ,urlStore: pre_url + '/code/cministry'
                                            ,fieldStore: ['mcode', 'minname']
                                            ,anchor: "95%"                                                              
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กอง
                                            hiddenName: 'pispersonel[dcode]'
                                            ,id: 'pispersonel[dcode]'
                                            ,fieldLabel: "กอง"
                                            ,valueField: 'dcode'
                                            ,displayField: 'division'
                                            ,urlStore: pre_url + '/code/cdivision'
                                            ,fieldStore: ['dcode', 'division']
                                            ,anchor: "95%"
                                        })
                                    ]
                                }
                                ,{
                                    width: 480
                                    ,layout: "form"
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//ระดับ
                                            fieldLabel: "ระดับ"
                                            ,hiddenName: 'pispersonel[c]'
                                            ,id: 'pispersonel[c]'
                                            ,valueField: 'ccode'
                                            ,displayField: 'cname'
                                            ,urlStore: pre_url + '/code/cgrouplevel'
                                            ,fieldStore: ['ccode', 'cname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                            fieldLabel: "ว./ว.ช/ชช."
                                            ,hiddenName: 'pispersonel[ptcode]'
                                            ,id: 'pispersonel[ptcode]'
                                            ,valueField: 'ptcode'
                                            ,displayField: 'ptname'
                                            ,urlStore: pre_url + '/code/cpostype'
                                            ,fieldStore: ['ptcode', 'ptname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                            fieldLabel: "ความเชี่ยวชาญ"
                                            ,hiddenName: 'pispersonel[epcode]'
                                            ,id: 'pispersonel[epcode]'
                                            ,valueField: 'epcode'
                                            ,displayField: 'expert'
                                            ,urlStore: pre_url + '/code/cexpert'
                                            ,fieldStore: ['epcode', 'expert']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กรม
                                            fieldLabel: "กรม"
                                            ,hiddenName: 'pispersonel[deptcode]'
                                            ,id: 'pispersonel[deptcode]'
                                            ,valueField: 'deptcode'
                                            ,displayField: 'deptname'
                                            ,urlStore: pre_url + '/code/cdept'
                                            ,fieldStore: ['deptcode', 'deptname']
                                            ,anchor: "95%" 
                                        })                                        
                                    ]


                                }
                            ]
                        }
                        ,{
                            xtype: "compositefield"
                            ,fieldLabel: "หน่วยงาน"
                            ,anchor: "95%"
                            ,items: [
                                     {
                                              xtype: "numberfield"
                                              ,id: "pispersonel[sdcode]"
                                              ,width: 80
                                              ,enableKeyEvents: true
                                              ,listeners: {
                                                       specialkey : function( el,e ){
                                                                Ext.getCmp("subdept_show_gov").setValue("");
                                                                if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
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
                                                                                  Ext.getCmp("pispersonel[sdcode]").setValue("");
                                                                                  Ext.getCmp("subdept_show_gov").setValue("");
                                                                               }
                                                                               else{
                                                                                  Ext.getCmp("pispersonel[sdcode]").setValue(obj.records[0].sdcode);
                                                                                  Ext.getCmp("subdept_show_gov").setValue(obj.records[0].subdeptname);
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
                                                                if (Ext.getCmp("subdept_show_gov").getValue() == ""){
                                                                         Ext.getCmp("pispersonel[sdcode]").setValue("");
                                                                         Ext.getCmp("subdept_show_gov").setValue("");    
                                                                }
                                                       }
                                                       
                                              }
                                        }
                                        ,{
                                                 xtype: "textfield"
                                                 ,id: "subdept_show_gov"
                                                 ,readOnly: true
                                                 ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:500px;"
                                        }
                                        ,{
                                                 xtype: "button"
                                                 ,id: "sdcode_button"
                                                 ,text: "..."
                                                 ,handler: function(){
                                                          searchSubdeptAll(Ext.getCmp("pispersonel[sdcode]"),Ext.getCmp("subdept_show_gov"));
                                                 }
                                        }
                                 ]
                        }
                        ,{
                            layout: "column"
                            ,items: [
                                {
                                    width: 480
                                    ,layout: "form"
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                            fieldLabel: "ฝ่าย/กลุ่มงาน"
                                            ,hiddenName: 'pispersonel[seccode]'
                                            ,id: 'pispersonel[seccode]'
                                            ,valueField: 'seccode'
                                            ,displayField: 'secname'
                                            ,urlStore: pre_url + '/code/csection'
                                            ,fieldStore: ['seccode', 'secname']
                                            ,anchor: "95%"                                                
                                        })
                                    ]
                                }
                                ,{
                                    width: 480
                                    ,layout: "form"
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//งาน
                                            fieldLabel: "งาน"
                                            ,hiddenName: 'pispersonel[jobcode]'
                                            ,id: 'pispersonel[jobcode]'
                                            ,valueField: 'jobcode'
                                            ,displayField: 'jobname'
                                            ,urlStore: pre_url + '/code/cjob'
                                            ,fieldStore: ['jobcode', 'jobname']
                                            ,anchor: "95%"
                                        }) 
                                    ]
                                }
                            ]
                        }
                        ,{
                            xtype: "textfield"
                            ,id: 'cmd[note]'
                            ,fieldLabel: "หมายเหตุ"
                            ,anchor: "95%"
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
            govActionForm.getForm().submit(
            { 
                method:'POST'
                ,waitTitle:'Saving Data'
                ,waitMsg:'Sending data...'
                ,success:function(){
                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย");
                    govActionForm.getForm().reset();
                    govActionReset();
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
            govActionForm.getForm().reset();
            Ext.getCmp("pispersonel[j18code]").getStore().load({
                params: {
                    j18code: 3
                    ,start: 0
                    ,limit: 10
                }
                ,callback :function(){
                    Ext.getCmp("pispersonel[j18code]").setValue(3);
                    loadMask.hide();
                }
           });            
        }
    }
] 

});

//-------------------------------------
// Panel Main
//-------------------------------------
var govActionPanel = new Ext.Panel({
    layout: "border"
    ,title: "คำสั่งปฏิบัติราชการ"
    ,items: [
        govActionForm
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
            Ext.getCmp("pispersonel[j18code]").getStore().load({
                    params: {
                             j18code: 3
                             ,start: 0
                             ,limit: 10
                    }
                    ,callback :function(){
                             Ext.getCmp("pispersonel[j18code]").setValue(3);
                             loadMask.hide();
                    }
           });
        }
    }
});
//-------------------------------------
// Function
//-------------------------------------
function personelGovAction(posid,show,id){
    personelNowSearch = new Ext.ux.grid.Search({
             iconCls: 'search'
             ,minChars: 3
             ,autoFocus: true
             ,position: "top"
             ,width: 200
    });
    personelNowFields = [
             ,{name: "prefix", type: "string"}
             ,{name: "fname", type: "string"}
             ,{name: "lname", type: "string"}
             ,{name: "posid", type: "string"}
             ,{name: "id", type: "string"}
    ];
    personelNowCols = [
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
         
    ];
        
    personelNowGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_personal/read"
            ,root: "records"
            ,autoLoad: false
            ,totalProperty: 'totalCount'
            ,fields: personelNowFields
            ,idProperty: 'id'
    });
        
    personelNowGrid = new Ext.grid.GridPanel({
            split: true
            ,store: personelNowGridStore
            ,columns: personelNowCols
            ,stripeRows: true
            ,loadMask: {msg:'Loading...'}
            ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
            ,plugins: [personelNowSearch]
            ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: personelNowGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
            })
            ,tbar: []
    });

    personelNowGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        posid.setValue(data_select.posid);
        show.setValue(data_select.prefix+data_select.fname+" "+data_select.lname);
        id.setValue(data_select.id);
        govActionSearchEdit(data_select.id);
        win.close();
    });
    
    if(!win){
            var win = new Ext.Window({
            title: ''
            ,height: 300
            ,width: 600
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,items: [personelNowGrid]
            });
    }
    win.show();	
    win.center();
    personelNowGridStore.load({params:{start: 0,limit: 20}});
}

function govActionSearchEdit(id){
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + "/info_perform_now/search_edit"
        ,params: {
            id: id
        }
        ,success: function(response,opts){
            obj = Ext.util.JSON.decode(response.responseText);
            data = obj.data.pispersonel;
            if (obj.success){
                Ext.getCmp("pispersonel[salary]").setValue(data.salary);
                Ext.getCmp("pispersonel[sdcode]").setValue(data.sdcode);
                Ext.getCmp("subdept_show_gov").setValue(data.now_subdept_show);
                Ext.getCmp("pispersonel[poscode]").getStore().load({
                    params: {
                        poscode: data.poscode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("pispersonel[poscode]").setValue(data.poscode);
                    }
                });
                Ext.getCmp("pispersonel[excode]").getStore().load({
                    params: {
                        excode: data.excode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("pispersonel[excode]").setValue(data.excode);
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
                Ext.getCmp("pispersonel[c]").getStore().load({
                    params: {
                        ccode: data.c
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("pispersonel[c]").setValue(data.c);
                    }
                });
                Ext.getCmp("pispersonel[ptcode]").getStore().load({
                    params: {
                        ptcode: data.ptcode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("pispersonel[ptcode]").setValue(data.ptcode);
                    }
               });
                Ext.getCmp("pispersonel[epcode]").getStore().load({
                    params: {
                        epcode: data.epcode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("pispersonel[epcode]").setValue(data.epcode);
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
                        loadMask.hide();
                        
                    }
                });
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

function govActionReset(){
    Ext.getCmp("pispersonel[posid]").setValue("");
    Ext.getCmp("pispersonel[id]").setValue("");
    Ext.getCmp("gov_name").setValue("");
    Ext.getCmp("pispersonel[salary]").setValue("");
    Ext.getCmp("pispersonel[sdcode]").setValue("");
    Ext.getCmp("subdept_show_gov").setValue("");
    
    Ext.getCmp("pispersonel[j18code]").clearValue();
    Ext.getCmp("pispersonel[poscode]").clearValue();
    Ext.getCmp("pispersonel[excode]").clearValue();
    Ext.getCmp("pispersonel[mincode]").clearValue();
    Ext.getCmp("pispersonel[dcode]").clearValue();
    Ext.getCmp("pispersonel[c]").clearValue();
    Ext.getCmp("pispersonel[ptcode]").clearValue();
    Ext.getCmp("pispersonel[epcode]").clearValue();
    Ext.getCmp("pispersonel[deptcode]").clearValue();
    Ext.getCmp("pispersonel[seccode]").clearValue();
    Ext.getCmp("pispersonel[jobcode]").clearValue();
    Ext.getCmp("pispersonel[j18code]").getStore().load({
            params: {
                     j18code: 3
                     ,start: 0
                     ,limit: 10
            }
            ,callback :function(){
                     Ext.getCmp("pispersonel[j18code]").setValue(3);
                     loadMask.hide();
            }
   });
}


