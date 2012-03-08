data_educationForm_url = "";
/********************************************************************/
/*Grid*/
/******************************************************************/    
var data_educationSearch = new Ext.ux.grid.Search({
     iconCls: 'search'
     ,minChars: 3
     ,autoFocus: true
     ,position: "top"
     ,width: 200
});
var data_educationFields = [
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

var data_educationCols = [
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

var data_educationGridStore = new Ext.data.JsonStore({
     url: pre_url + "/info_personal/read"
     ,root: "records"
     ,autoLoad: false
     ,totalProperty: 'totalCount'
     ,fields: data_educationFields
     ,idProperty: 'id'
});

var data_educationGrid = new Ext.grid.GridPanel({
     region: 'center'
      ,split: true
      ,store: data_educationGridStore
      ,columns: data_educationCols
      ,stripeRows: true
      ,loadMask: {msg:'Loading...'}
      ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
      ,plugins: [data_educationSearch]
      ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: data_educationGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
      })
      ,tbar: ["&nbsp;"]
});
data_educationGrid.on('rowdblclick', function(grid, rowIndex, e ) {
      data_select = grid.getSelectionModel().getSelected().data;
      data_personel_id = data_select.id;
      searchEditEducation(data_select);
});
function searchEditEducation(data_select){
    tab_personel.getActiveTab().setTitle("การศึกษา ( " +data_select.name+ " )")
     tab_personel.getActiveTab().getLayout().setActiveItem(panelEducation);
     data_educationForm.disable();
     data_education_detailGridStore.baseParams = {
             id:data_select.id
     }
     data_education_detailGridStore.load(); 
}
function searchEducationById(personel_id){
     loadMask.show();
     Ext.Ajax.request({
              url: pre_url + "/info_personal/search_id"
              ,params: {
                       id: personel_id
              }
              ,success: function(response,opts){
                       obj = Ext.util.JSON.decode(response.responseText);
                        searchEditEducation(obj.data[0]);
                        loadMask.hide();
              }
              ,failure: function(response,opts){
                       Ext.Msg.alert("สถานะ",response.statusText);
                       loadMask.hide();
              }
     });
}
/********************************************************************/
/*Grid  Education*/
/******************************************************************/
var expander_data_education_detail = new Ext.ux.grid.RowExpander({
     tpl: new Ext.Template(
                       '<table>',
                                '<tr><td with="50px" align="right">วันที่สำเร็จการศึกษา:</td><td> {enddate}</td></tr>',
                                '<tr><td with="50px" align="right">วุฒิการศึกษา: </td><td>{qualify}</td></tr>',
                                '<tr><td with="50px" align="right">ระดับการศึกษา: </td><td>{edulevel}</td></tr>',
                                '<tr><td with="50px" align="right">วิชาเอก </td><td>{major}</td></tr>',
                                '<tr><td with="50px" align="right">สถาบัน: </td><td>{institute}</td></tr>',
                                '<tr><td with="50px" align="right">ประเทศ: </td><td>{coname}</td></tr>',
                       '</table>'
              )
});

var data_education_detailFields = [
    {name: "id", type: "string"}
    ,{name: "eorder", type: "int"}
    ,{name: "edulevel", type: "string"}
    ,{name: "enddate", type: "string"}
    ,{name: "flag", type: "string"}
    ,{name: "maxed", type: "string"}
    ,{name: "qualify", type: "string"}
    ,{name: "institute", type: "string"}
    ,{name: "coname", type: "string"}
];

var data_education_detailCols = [
         expander_data_education_detail
        ,{
                header: "#"
                ,width: 30
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }		
        ,{header: "ระดับการศึกษา",width: 150, sortable: false, dataIndex: 'edulevel'}
        ,{header: "วันที่จบการศึกษา",width: 150, sortable: false, dataIndex: 'enddate'}
        ,{header: "เป็นวุฒิในตำแหน่ง",width: 150, sortable: false, dataIndex: 'flag'}
        ,{header: "เป็นวุฒิสูงสุด",width: 150, sortable: false, dataIndex: 'maxed'}
];

var data_education_detailGridStore = new Ext.data.JsonStore({
        url: pre_url + "/info_education/read"
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: data_education_detailFields
        ,idProperty: 'eorder'
});

var data_education_detailGrid = new Ext.grid.GridPanel({
        region: 'center'
        ,split: true
        ,store: data_education_detailGridStore
        ,columns: data_education_detailCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
        ,plugins: [expander_data_education_detail]
                    ,tbar: [
                            {
                                    text: "	เพิ่ม"
                                    ,iconCls: "table-add"
                                    ,handler: function (){
                                         data_educationForm.getForm().reset();
                                         data_educationForm.enable();
                                         data_educationForm_url = pre_url + "/info_education/create";
                                         Ext.getCmp("id").setValue(data_personel_id);
                                    }
                            }
                            ,"-",{
                                    ref: '../removeBtn'
                                    ,text: 'ลบ'
                                    ,tooltip: 'ลบ'
                                    ,iconCls: 'table-delete'
                                    ,disabled: true
                                    ,handler: function(){
                                            Ext.Msg.confirm('สถานะ', 'ต้องการลบใช่หรือไม่', function(btn, text){			
                                                    if (btn == 'yes')
                                                    {				
                                                            loadMask.show();
                                                            Ext.Ajax.request({
                                                                    url: pre_url + '/info_education/delete' , 
                                                                    params: { 
                                                                            id: data_education_detailGrid.getSelectionModel().getSelections()[0].data.id
                                                                            ,eorder: data_education_detailGrid.getSelectionModel().getSelections()[0].data.eorder
                                                                            ,random: Math.random()
                                                                    },	
                                                                    failure: function ( result, request) { 
                                                                            loadMask.hide();
                                                                            Ext.MessageBox.alert('สถานะ', "Error: "+result.responseText); 
                                                                    },
                                                                    success: function ( result, request ) { 
                                                                            loadMask.hide();
                                                                            var obj = Ext.util.JSON.decode(result.responseText); 
                                                                            if (obj.success == false)
                                                                            {
                                                                                    Ext.MessageBox.alert('สถานะ', 'ไม่สามารถลบได้ <br> Error: ' + obj.msg);
                                                                                    
                                                                            }
                                                                            else if (obj.success == true)
                                                                            {
                                                                                    Ext.MessageBox.alert('สถานะ', 'ลบเสร็จเรียบร้อย',function(btn, text){
                                                                                                    if (btn == 'ok'){
                                                                                                            data_education_detailGridStore.reload();
                                                                                                            data_education_detailGrid.getSelectionModel().clearSelections()
                                                                                                            data_educationForm.getForm().reset();
                                                                                                            data_educationForm.disable();
                                                                                                            
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
                            },"-",{
                                    text: "ปิด"
                                    ,iconCls: "delete"
                                    ,handler: function(){                 
                                         tab_personel.getActiveTab().setTitle("การศึกษา");
                                         data_personel_id = "";
                                         tab_personel.getActiveTab().getLayout().setActiveItem(data_educationGrid); 
                                    }
                            }
                    ]
});
data_education_detailGrid.getSelectionModel().on('selectionchange', function(sm){
     data_education_detailGrid.removeBtn.setDisabled(sm.getCount() < 1);       
});
data_education_detailGrid.on('rowdblclick', function(grid, rowIndex, e ) {
     record = grid.getSelectionModel().getSelected();
     data_educationForm_url = pre_url + "/info_education/edit";
     data_educationForm.enable();
     data_educationForm.getForm().reset();
     loadMask.show();
     Ext.Ajax.request({
             url: pre_url + '/info_education/search_edit'
             ,params: {
                     id: record.data.id
                     ,eorder: record.data.eorder
             }
             ,success: function(response, opts) {
                      var obj = Ext.decode(response.responseText);
                      if (obj.success){
                         data = obj.data.piseducation;
                         Ext.getCmp("id").setValue(data.id);
                         Ext.getCmp("eorder").setValue(data.eorder);
                         if (data.status == "1"){
                             Ext.getCmp("status1").setValue(1); 
                         }
                         else if (data.status == "0"){
                             Ext.getCmp("status0").setValue(0); 
                         }
                         Ext.getCmp("piseducation[enddate]").setValue(to_date_app(data.enddate));
                         Ext.getCmp("piseducation[regisno]").setValue(data.regisno);
                         Ext.getCmp("piseducation[institute]").setValue(data.institute);
                         Ext.getCmp("piseducation[flag]").setValue(data.flag);
                         Ext.getCmp("piseducation[maxed]").setValue(data.maxed);
                         Ext.getCmp("piseducation[refno]").setValue(data.refno);
                         Ext.getCmp("piseducation[qcode]").getStore().load({
                                  params: {
                                           qcode: data.qcode
                                           ,start: 0
                                           ,limit: 10
                                  }
                                  ,callback :function(){
                                           Ext.getCmp("piseducation[qcode]").setValue(data.qcode);
                                  }
                         });
                         Ext.getCmp("piseducation[ecode]").getStore().load({
                                  params: {
                                           ecode: data.ecode
                                           ,start: 0
                                           ,limit: 10
                                  }
                                  ,callback :function(){
                                           Ext.getCmp("piseducation[ecode]").setValue(data.ecode);
                                  }
                         });
                         Ext.getCmp("piseducation[macode]").getStore().load({
                                  params: {
                                           macode: data.macode
                                           ,start: 0
                                           ,limit: 10
                                  }
                                  ,callback :function(){
                                           Ext.getCmp("piseducation[macode]").setValue(data.macode);
                                  }
                         });
                         Ext.getCmp("piseducation[cocode]").getStore().load({
                                  params: {
                                           cocode: data.cocode
                                           ,start: 0
                                           ,limit: 10
                                  }
                                  ,callback :function(){
                                           Ext.getCmp("piseducation[cocode]").setValue(data.cocode);
                                           loadMask.hide();
                                  }
                         });
                      }
             }
             ,failure: function(response, opts) {
                     Ext.Msg.alert("สถานะ", response.statusText);
                     loadMask.hide();
             }
     });         
});
/********************************************************************/
/*Form*/
/******************************************************************/
var data_educationForm = new Ext.form.FormPanel({
             region: "south"
            ,height: 400
            ,autoScroll: true
            ,split: true
            ,bodyStyle: "padding:5px"
            ,labelAlign: "right"	
            ,frame: true
            ,monitorValid: true
            ,labelWidth: 120
            ,defaults: {
                    msgTarget: "side"
            }
            ,items: [
                     {
                          xtype: "hidden"
                          ,id: "id"
                     }
                     ,{
                          xtype: "hidden"
                          ,id: "eorder"
                     }
                    ,{
                            xtype: 'radiogroup'
                            ,width: 200
                            ,id: "sadas"
                            ,fieldLabel: 'สถานะการศึกษา'
                            ,items: [
                                    {boxLabel: 'สำเร็จการศึกษา', name: 'status',id: 'status1',inputValue:1,checked:true}
                                    ,{boxLabel: 'ลาศึกษาต่อ', name: 'status',id: 'status0',inputValue:0}
                            ]
                    }
                    ,{
                            xtype: "datefield"
                            ,fieldLabel: "วันที่สำเร็จการศึกษา"
                            ,id: "piseducation[enddate]"
                            ,format: "d/m/Y"
                    }
                    ,{
                            xtype: "textfield"
                            ,id: "piseducation[regisno]"
                            ,fieldLabel: "เอกสารอ้างอิง"
                            ,anchor: "90%"
                    }
                     ,new Ext.ux.form.PisComboBox({//วุฒิการศึกษา
                          fieldLabel: 'วุฒิการศึกษา'
                          ,id: 'piseducation[qcode]'
                          ,hiddenName:'piseducation[qcode]'
                          ,valueField: 'qcode'
                          ,displayField: 'qualify'
                          ,urlStore: pre_url + '/code/cqualify'
                          ,fieldStore: ['qcode', 'qualify']
                          ,width: 400
                     })                        
                     ,new Ext.ux.form.PisComboBox({//ระบดับการการศึกษา
                          fieldLabel: 'ระบดับการการศึกษา'
                          ,id: 'piseducation[ecode]'
                          ,hiddenName:'piseducation[ecode]'
                          ,valueField: 'ecode'
                          ,displayField: 'edulevel'
                          ,urlStore: pre_url + '/code/cedulevel'
                          ,fieldStore: ['ecode', 'edulevel']
                          ,width: 400
                     })
                     ,new Ext.ux.form.PisComboBox({//วิชาเอก
                          fieldLabel: 'วิชาเอก'
                          ,id: 'piseducation[macode]'
                          ,hiddenName:'piseducation[macode]'
                          ,valueField: 'macode'
                          ,displayField: 'major'
                          ,urlStore: pre_url + '/code/cmajor'
                          ,fieldStore: ['macode', 'major']
                          ,width: 400
                     })
                    ,{//ชื่อสถานบัน
                            xtype: "textfield"
                            ,id: "piseducation[institute]"
                            ,fieldLabel: "ชื่อสถานบัน"
                            ,anchor: "50%"
                    }
                     ,new Ext.ux.form.PisComboBox({//ประเทศ
                          fieldLabel: 'ประเทศ'
                          ,id: 'piseducation[cocode]'
                          ,hiddenName:'piseducation[cocode]'
                          ,valueField: 'cocode'
                          ,displayField: 'coname'
                          ,urlStore: pre_url + '/code/ccountry'
                          ,fieldStore: ['cocode', 'coname']
                          ,width: 400
                     })
                    ,{
                          xtype: "compositefield"
                          ,items: [
                               {xtype:"xcheckbox",boxLabel: 'กำหนดเป็นวุฒิในตำแหน่ง', id: 'piseducation[flag]',submitOffValue:'0',submitOnValue:'1'}
                               ,{xtype:"xcheckbox",boxLabel: 'กำหนดเป็นวุฒิสูงสุด', id: 'piseducation[maxed]',submitOffValue:'0',submitOnValue:'1'}
                          ]
                    }
                    ,{
                            xtype: "textfield"
                            ,fieldLabel: "หมายเหตุ"
                            ,anchor: "90%"
                            ,id: "piseducation[refno]"
                    }
            ]
            ,buttons:[
                    { 
                            text:'บันทึก'
                            ,formBind: true 
                            ,handler:function(){
                                    data_educationForm.getForm().submit(
                                    { 
                                            method:'POST'
                                            ,url: data_educationForm_url
                                            ,waitTitle:'Saving Data'
                                            ,waitMsg:'Sending data...'
                                            ,success:function(){		
                                            
                                                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                    if (btn == 'ok')
                                                                    {
                                                                            data_educationForm.getForm().reset();
                                                                            data_educationForm.disable();
                                                                            data_education_detailGridStore.reload();
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
                    }
                    ,{
                            text: "ยกเลิก"
                            ,handler: function	(){
                               data_educationForm.getForm().reset();
                               data_educationForm.disable();
                               tab_personel.getActiveTab().getLayout().setActiveItem(data_education_detailGrid);
                               data_educationGridStore.load({ params: { start: 0, limit: 20} });
                            }
                    }
            ]

    });
/********************************************************************/
/*Panel Education*/
/******************************************************************/
 var panelEducation  = new Ext.Panel({
      layout:  "border"
      ,items: [
             data_education_detailGrid
             ,data_educationForm
      ]
 });