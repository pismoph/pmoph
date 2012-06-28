//-------------------------------------
// Form Center
//-------------------------------------
var editCommandForm = new Ext.FormPanel({
    labelWidth: 100
    ,autoScroll: true
    ,url: pre_url + '/edit_command/process_edit_command'
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
                {
                    xtype: "compositefield"
                    ,fieldLabel: "เลขที่ตำแหน่ง"
                    ,anchor: "100%"
                    ,items: [
                        {
                            xtype: "numberfield"
                            ,id: "pisposhis[posid]"
                            ,width: 100
                            ,enableKeyEvents: true
                            ,allowBlank: false
                            ,listeners: {
                                focus: function(el){
                                    posid = el.getValue();
                                    Ext.getCmp("poshis_name").setValue("");
                                    editCommandForm.getForm().reset(); 
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
                                                    Ext.getCmp("pisposhis[id]").setValue(obj.data[0].id);
                                                    Ext.getCmp("poshis_name").setValue(obj.data[0].name);
                                                    Ext.getCmp("pisposhis[posid]").setValue(obj.data[0].posid);
                                                }
                                                else{
                                                    Ext.getCmp("pisposhis[id]").setValue("");
                                                    Ext.getCmp("poshis_name").setValue("");
                                                    Ext.getCmp("pisposhis[posid]").setValue("");
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
                                    if (Ext.getCmp("poshis_name").getValue() == ""){
                                       Ext.getCmp("pisposhis[id]").setValue("");
                                       Ext.getCmp("poshis_name").setValue("");
                                       Ext.getCmp("pisposhis[posid]").setValue("");
                                       editCommandForm.getForm().reset(); 
                                    }
                                }
                            }
                        }
                        ,{
                            xtype: "button"
                            ,text: "..."
                            ,handler: function(){
                                EditCommandpersonelNow(Ext.getCmp("pisposhis[posid]"),Ext.getCmp("poshis_name"),Ext.getCmp("pisposhis[id]"));
                            }
                        }
                        ,{
                            xtype: "displayfield"
                            ,value: "ชื่อ-นามสกุล"
                            ,style: "padding: 4px;text-align: right;padding-left: 10px"
                        }
                        ,{
                            xtype: "textfield"
                            ,id: "poshis_name"
                            ,readOnly: true
                            ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                        }
                        
                        ,{
                            xtype: "hidden"
                            ,id:  "pisposhis[id]"
                            ,allowBlank: false
                        }
                    ]
                }
                ,{
                    xtype: "compositefield"
                    ,fieldLabel: "เลือกคำสั่งแก้ไข...."
                    ,items: [
                        {
                            xtype: "textfield"
                            ,id: "pisposhis[refcmnd]"
                            ,readOnly: true
                            ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                            ,allowBlank: false
                        }
                        ,{
                            xtype: "button"
                            ,text: "..."
                            ,handler: function(){
                                if (Ext.getCmp("pisposhis[id]").getValue() != ""){
                                    poshisNow(Ext.getCmp("pisposhis[refcmnd]"),Ext.getCmp("pisposhis[historder]"),Ext.getCmp("pisposhis[id]") );
                                }
                            }
                        }
                        ,{
                            xtype: "hidden"
                            ,id: "pisposhis[historder]"
                        }
                    ]
                }
                ,{
                    xtype: "fieldset"
                    ,items: [
                        {
                            layout: "column"
                            ,items: [
                                {
                                    width: 480
                                    ,layout: "form"
                                    ,items: [
                                        new Ext.ux.form.PisComboBox({//การเคลื่อนไหว
                                            fieldLabel: 'การเคลื่อนไหว'
                                            ,hiddenName: 'pisposhis[updcode]'
                                            ,id: 'pisposhis[updcode]'
                                            ,anchor: "95%"
                                            ,valueField: 'updcode'
                                            ,displayField: 'updname'
                                            ,urlStore: pre_url + '/code/cupdate'
                                            ,fieldStore: ['updcode', 'updname']
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                            fieldLabel: "ตำแหน่งสายงาน"
                                            ,hiddenName: 'pisposhis[poscode]'
                                            ,id: 'pisposhis[poscode]'
                                            ,valueField: 'poscode'
                                            ,displayField: 'posname'
                                            ,urlStore: pre_url + '/code/cposition'
                                            ,fieldStore: ['poscode', 'posname']
                                            ,anchor: "95%"                                                                                 
                                        })
                                    ]
                                }
                                ,{
                                    width: 480
                                    ,layout: "form"
                                    ,items: [
                                        {
                                            xtype: "datefield"
                                            ,id: "pisposhis[forcedate]"
                                            ,fieldLabel: "วันที่มีผลบังคับใช้"
                                            ,format: "d/m/Y"
                                        }
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
                                    ]
                                }
                            ]
                        }
                        ,{
                            layout: "column"
                            ,items: [
                                {
                                    width: 320
                                    ,layout: "form"
                                    ,items: [
                                        {
                                            xtype: "numericfield"
                                            ,id: "pisposhis[salary]"
                                            ,fieldLabel: "เงินเดือน"
                                        }
                                        ,{
                                            xtype: "numberfield"
                                            ,id: "pisposhis[uppercent]"
                                            ,fieldLabel: "ร้อยละที่ได้เลื่อน"
                                        }
                                    ]
                                }
                                ,{
                                    width: 320
                                    ,layout: "form"
                                    ,items: [
                                        {
                                            xtype: "numericfield"
                                            ,id: "pisposhis[posmny]"
                                            ,fieldLabel: "เงินประจำตำแหน่ง"
                                        }
                                        ,{
                                            xtype: "numericfield"
                                            ,id: "pisposhis[upsalary]"
                                            ,fieldLabel: "ค่าตอบแทนพิเศษ"
                                        }
                                    ]
                                }
                                ,{
                                    width: 320
                                    ,layout: "form"
                                    ,items: [
                                        {
                                            xtype: "numericfield"
                                            ,fieldLabel: "เงินพสร"
                                            ,id: "pisposhis[spmny]"
                                        }       
                                    ]
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
                                        new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                            fieldLabel: "ว./ว.ช/ชช."
                                            ,hiddenName: 'pisposhis[ptcode]'
                                            ,id: 'pisposhis[ptcode]'
                                            ,valueField: 'ptcode'
                                            ,displayField: 'ptname'
                                            ,urlStore: pre_url + '/code/cpostype'
                                            ,fieldStore: ['ptcode', 'ptname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                            fieldLabel: "ตำแหน่งบริหาร"
                                            ,hiddenName: 'pisposhis[excode]'
                                            ,id: 'pisposhis[excode]'
                                            ,valueField: 'excode'
                                            ,displayField: 'exname'
                                            ,urlStore: pre_url + '/code/cexecutive'
                                            ,fieldStore: ['excode', 'exname']
                                            ,anchor: "95%"
                                        })
                                        ,{
                                            xtype: "displayfield"
                                            ,value: "&nbsp;"
                                        }
                                        ,new Ext.ux.form.PisComboBox({//กระทรวง
                                            fieldLabel: "กระทรวง"
                                            ,hiddenName: 'pisposhis[mcode]'
                                            ,id: 'pisposhis[mcode]'
                                            ,valueField: 'mcode'
                                            ,displayField: 'minname'
                                            ,urlStore: pre_url + '/code/cministry'
                                            ,fieldStore: ['mcode', 'minname']
                                            ,anchor: "95%"
                                            
                                       })
                                        ,new Ext.ux.form.PisComboBox({//กอง
                                                hiddenName: 'pisposhis[dcode]'
                                                ,id: 'pisposhis[dcode]'
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
                                        {
                                            xtype: "displayfield"
                                            ,value: "&nbsp;"
                                            ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                        }
                                        ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                            fieldLabel: "ความเชี่ยวชาญ"
                                            ,hiddenName: 'pisposhis[epcode]'
                                            ,id: 'pisposhis[epcode]'
                                            ,valueField: 'epcode'
                                            ,displayField: 'expert'
                                            ,urlStore: pre_url + '/code/cexpert'
                                            ,fieldStore: ['epcode', 'expert']
                                            ,anchor: "95%"
                                        })
                                        ,{
                                            xtype: "displayfield"
                                            ,value: "&nbsp;"
                                        }
                                        ,new Ext.ux.form.PisComboBox({//กรม
                                            fieldLabel: "กรม"
                                            ,hiddenName: 'pisposhis[deptcode]'
                                            ,id: 'pisposhis[deptcode]'
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
                            ,anchor: "100%"
                            ,items: [
                                {
                                    xtype: "numberfield"
                                    ,id: "pisposhis[sdcode]"
                                    ,width: 80
                                    ,enableKeyEvents: true
                                    ,listeners: {
                                        keyup: function( el,e ){
                                            Ext.getCmp("his_subdept_show").setValue("");
                                        }
                                        ,specialkey : function( el,e ){
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
                                    ,text: "..."
                                    ,handler: function(){
                                        searchSubdeptAll(Ext.getCmp("pisposhis[sdcode]"),Ext.getCmp("his_subdept_show"));
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
                                            ,hiddenName: 'pisposhis[seccode]'
                                            ,id: 'pisposhis[seccode]'
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
                                            ,hiddenName: 'pisposhis[jobcode]'
                                            ,id: 'pisposhis[jobcode]'
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
                            xtype: "displayfield"
                            ,value: "&nbsp;"
                            ,style: "padding: 10px;text-align: right;padding-left: 10px"
                        }
                        ,{
                            xtype: "textfield"
                            ,id: 'pisposhis[note]'
                            ,fieldLabel: "หมายเหตุ"
                            ,anchor: "95%"
                        }
                    ]
                }
                ,{
                    xtype: "checkboxgroup"
                    ,columns: 2
                    ,items: [
                        { xtype: "xcheckbox" ,boxLabel: "ปรับปรุงข้อมูลตำแหน่ง(จ.18)...ถือจ่ายปัจจุบัน",id: "update_pisj18",submitOffValue:'0',submitOnValue:'1' }
                        ,{ xtype: "xcheckbox" ,boxLabel: "ปรับปรุงข้อมูลปฎิบัติราชการปัจจุบัน",id: "update_pispersonel",submitOffValue:'0',submitOnValue:'1' }
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
            editCommandForm.getForm().submit(
            { 
                method:'POST'
                ,waitTitle:'Saving Data'
                ,waitMsg:'Sending data...'
                ,success:function(){
                    posid = Ext.getCmp("pisposhis[posid]").getValue();
                    full_name = Ext.getCmp("poshis_name").getValue();
                    id = Ext.getCmp("pisposhis[id]").getValue();
                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย");
                    editCommandForm.getForm().reset();
                    Ext.getCmp("pisposhis[posid]").setValue(posid);
                    Ext.getCmp("poshis_name").setValue(full_name);
                    Ext.getCmp("pisposhis[id]").setValue(id);
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
            editCommandForm.getForm().reset();           
        }
    }
] 

});

//-------------------------------------
// Panel Main
//-------------------------------------
var editCommandPanel = new Ext.Panel({
    layout: "border"
    ,title: "แก้ไขคำสั่ง"
    ,items: [
        editCommandForm
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
        }
    }
});
//-----------------------------------
// Function
//-----------------------------------
function poshisNow(show,norder,id){
    poshisNowSearch = new Ext.ux.grid.Search({
             iconCls: 'search'
             ,minChars: 3
             ,autoFocus: true
             ,position: "top"
             ,width: 200
    });
    poshisNowFields = [
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
    poshisNowCols = [
        {header: "ลำดับที่",width: 80, sortable: false, dataIndex: 'historder'} 
        ,{header: "คำสั่ง",width: 300, sortable: false, dataIndex: 'refcmnd'}
        ,{header: "วันที่มีผลบังคับใช้",width: 150, sortable: false, dataIndex: 'forcedate'}
    ];
        
    poshisNowGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_pisposhis/read"
            ,root: "records"
            ,autoLoad: false
            ,totalProperty: 'totalCount'
            ,fields: poshisNowFields
            ,idProperty: 'historder'
    });
        
    poshisNowGrid = new Ext.grid.GridPanel({
            split: true
            ,store: poshisNowGridStore
            ,columns: poshisNowCols
            ,stripeRows: true
            ,loadMask: {msg:'Loading...'}
            ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
            ,plugins: [poshisNowSearch]
            ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: poshisNowGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
            })
            ,tbar: []
    });

    poshisNowGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        show.setValue(data_select.refcmnd);
        norder.setValue(data_select.historder);
        searchEditCommand(data_select.id,data_select.historder)
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
            ,items: [poshisNowGrid]
            });
    }
    win.show();	
    win.center();
    poshisNowGridStore.baseParams = {
        id: id.getValue()
    }
    poshisNowGridStore.load({params:{start: 0,limit: 20}});
}

function searchEditCommand(id,historder){
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
                Ext.getCmp("pisposhis[forcedate]").setValue(to_date_app(data.forcedate));
                Ext.getCmp("pisposhis[salary]").setValue(data.salary);
                Ext.getCmp("pisposhis[uppercent]").setValue(data.uppercent);
                Ext.getCmp("pisposhis[posmny]").setValue(data.posmny);
                Ext.getCmp("pisposhis[upsalary]").setValue(data.upsalary);
                Ext.getCmp("pisposhis[spmny]").setValue(data.spmny);
                Ext.getCmp("pisposhis[sdcode]").setValue(data.sdcode);
                Ext.getCmp("his_subdept_show").setValue(data.his_subdept_show);
                Ext.getCmp("pisposhis[note]").setValue(data.note);
                
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

function EditCommandpersonelNow(posid,show,id){
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
        editCommandForm.getForm().reset(); 
        data_select = grid.getSelectionModel().getSelected().data;
        posid.setValue(data_select.posid);
        show.setValue(data_select.prefix+data_select.fname+" "+data_select.lname);
        id.setValue(data_select.id);
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

