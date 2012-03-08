j18Form_url = ""
work_place = {
         mcode: "pisj18[mincode]"
         ,deptcode: "pisj18[deptcode]"
         ,dcode: "pisj18[dcode]"
         ,sdcode: "pisj18[sdcode]"
         ,sdcode_show: "subdept_show"
         ,sdcode_button: "sdcode_button"
         ,seccode: "pisj18[seccode]"
         ,jobcode: "pisj18[jobcode]"
}
/***********************************************************************/
//search j18
/************************************************************************/
var panleSearchJ18 = new Ext.Panel({
         region: "north"
         ,collapsible: true
         ,height: 140
         ,border: false
         ,autoScroll: true
         ,frame: true
         ,items: [
                  {
                           width: 1000
                           ,style: "padding-left:50%;margin-left:-487px"
                           ,items: [
                                    {
                                             layout: "hbox"
                                             ,border: false
                                             ,layoutConfig: {
                                                      pack: 'center'
                                                      ,align: 'middle'
                                                      ,padding: 5
                                             }
                                             ,items: [
                                                      {
                                                               layout: "form"
                                                               ,labelWidth: 100
                                                               ,labelAlign: "right"
                                                               ,width: 950
                                                               ,border: false
                                                               ,items: [
                                                                        {
                                                                                 layout: "column"
                                                                                 ,items: [
                                                                                          {
                                                                                                   width: 300
                                                                                                   ,layout: "form"
                                                                                                   ,items: [
                                                                                                            new Ext.ux.form.PisComboBox({//จังหวัด
                                                                                                                     fieldLabel: 'จังหวัด'
                                                                                                                     ,hiddenName: 'provcode'
                                                                                                                     ,id: 'idprovcode'
                                                                                                                     ,valueField: 'provcode'
                                                                                                                     ,displayField: 'provname'
                                                                                                                     ,urlStore: pre_url + '/code/cprovince'
                                                                                                                     ,fieldStore: ['provcode', 'provname']
                                                                                                                     ,anchor: "100%"
                                                                                                                     ,listeners: {
                                                                                                                              select: function( combo,record,  index ) {
                                                                                                                                       delete(Ext.getCmp("idamcode").getStore().baseParams["provcode"]);
                                                                                                                                       if (Ext.getCmp("idamcode").getStore().lastOptions && Ext.getCmp("idamcode").getStore().lastOptions.params) {
                                                                                                                                                delete(Ext.getCmp("idamcode").getStore().lastOptions.params["provcode"]);					
                                                                                                                                       }
                                                                                                                                       if (combo.getValue() != ""){											
                                                                                                                                                Ext.getCmp("idamcode").clearValue();
                                                                                                                                                Ext.getCmp("idtmcode").clearValue();
                                                                                                                                                Ext.getCmp("idprovcode").enable();											
                                                                                                                                                Ext.getCmp("idamcode").enable();
                                                                                                                                                Ext.getCmp("idsdcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdcode").disable();
                                                                                                                                                Ext.getCmp("idsdtcode").clearValue(); 
                                                                                                                                                Ext.getCmp("idtmcode").disable();											
                                                                                                                                                Ext.getCmp("idamcode").getStore().baseParams = {
                                                                                                                                                         provcode: combo.getValue()
                                                                                                                                                }
                                                                                                                                                Ext.getCmp("idamcode").getStore().load({ params: { start: 0, limit: 10} });
                                                                                                                                       }
                                                                                                                              }
                                                                                                                              ,blur: function(combo){
                                                                                                                                       if (combo.getValue() == combo.getRawValue()){
                                                                                                                                                combo.clearValue();
                                                                                                                                                delete(Ext.getCmp("idamcode").getStore().baseParams["provcode"]);
                                                                                                                                                if (Ext.getCmp("idamcode").getStore().lastOptions && Ext.getCmp("idamcode").getStore().lastOptions.params) {
                                                                                                                                                         delete(Ext.getCmp("idamcode").getStore().lastOptions.params["provcode"]);					
                                                                                                                                                }         
                                                                                                                                                Ext.getCmp("idamcode").clearValue();
                                                                                                                                                Ext.getCmp("idtmcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdtcode").clearValue();
                                                                                                                                                Ext.getCmp("idprovcode").enable();											
                                                                                                                                                Ext.getCmp("idamcode").disable();
                                                                                                                                                Ext.getCmp("idsdcode").disable();
                                                                                                                                                Ext.getCmp("idtmcode").disable();                                                                                                                                                
                                                                                                                                       }                                                                                                                                    
                                                                                                                              }
                                                                                                                     }
                                                                                                            })
                                                                                                            ,new Ext.ux.form.PisComboBox({//ประเภทหน่วยงาน
                                                                                                                     fieldLabel: 'ประเภทหน่วยงาน'
                                                                                                                     ,hiddenName: 'sdtcode'
                                                                                                                     ,id: 'idsdtcode'
                                                                                                                     ,urlStore: pre_url + '/code/csubdepttype'
                                                                                                                     ,fieldStore: ['sdtcode', 'subdepttype']
                                                                                                                     ,valueField: 'sdtcode'
                                                                                                                     ,displayField: 'subdepttype'
                                                                                                                     ,anchor: "100%"
                                                                                                                     ,listeners: {
                                                                                                                              select: function( combo,record,  index ) {
                                                                                                                                       Ext.getCmp("idsdcode").clearValue();
                                                                                                                                       delete(Ext.getCmp("idsdcode").getStore().baseParams["provcode"]);
                                                                                                                                       delete(Ext.getCmp("idsdcode").getStore().baseParams["amcode"]);
                                                                                                                                       delete(Ext.getCmp("idsdcode").getStore().baseParams["tmcode"]);
                                                                                                                                       delete(Ext.getCmp("idsdcode").getStore().baseParams["sdtcode"]);
                                                                                                                                       if (Ext.getCmp("idsdcode").getStore().lastOptions && Ext.getCmp("idsdcode").getStore().lastOptions.params) {
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["provcode"]);		
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["amcode"]);		
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["tmcode"]);		
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["sdtcode"]);											
                                                                                                                                       }
                                                                                                                                       if (combo.getValue() != ""){
                                                                                                                                                Ext.getCmp("idsdcode").enable();											
                                                                                                                                                Ext.getCmp("idsdcode").getStore().baseParams = {
                                                                                                                                                         provcode: Ext.getCmp("idprovcode").getValue()
                                                                                                                                                         ,amcode: Ext.getCmp("idamcode").getValue()
                                                                                                                                                         ,tmcode: Ext.getCmp("idtmcode").getValue()
                                                                                                                                                         ,sdtcode: Ext.getCmp("idsdtcode").getValue()
                                                                                                                                                }
                                                                                                                                                Ext.getCmp("idsdcode").getStore().load({ params: { start: 0, limit: 10} });
                                                                                                                                       }
                                                                                                                              }
                                                                                                                              ,blur: function(combo){
                                                                                                                                       if (combo.getValue() == combo.getRawValue()){
                                                                                                                                                combo.clearValue();
                                                                                                                                                Ext.getCmp("idsdcode").clearValue();
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().baseParams["provcode"]);
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().baseParams["amcode"]);
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().baseParams["tmcode"]);
                                                                                                                                                delete(Ext.getCmp("idsdcode").getStore().baseParams["sdtcode"]);
                                                                                                                                                if (Ext.getCmp("idsdcode").getStore().lastOptions && Ext.getCmp("idsdcode").getStore().lastOptions.params) {
                                                                                                                                                         delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["provcode"]);		
                                                                                                                                                         delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["amcode"]);		
                                                                                                                                                         delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["tmcode"]);		
                                                                                                                                                         delete(Ext.getCmp("idsdcode").getStore().lastOptions.params["sdtcode"]);											
                                                                                                                                                }
                                                                                                                                                Ext.getCmp("idsdcode").disable();
                                                                                                                                       }                                                                                                                                    
                                                                                                                              }                                                                                                                              
                                                                                                                     }
                                                                                                            })
                                                                                                   ]
                                                                                          },{
                                                                                                   width: 300
                                                                                                   ,layout: "form"
                                                                                                   ,items: [
                                                                                                            new Ext.ux.form.PisComboBox({//อำเภอ
                                                                                                                     fieldLabel: 'อำเภอ'
                                                                                                                     ,disabled: true
                                                                                                                     ,hiddenName: 'amcode'
                                                                                                                     ,id: 'idamcode'
                                                                                                                     ,valueField: 'amcode'
                                                                                                                     ,displayField: 'amname'
                                                                                                                     ,urlStore: pre_url + '/code/camphur'
                                                                                                                     ,fieldStore: ['amcode', 'amname']                                                                                                                     
                                                                                                                     ,anchor: "100%"
                                                                                                                     ,listeners: {
                                                                                                                              select: function( combo,record,  index ) {
                                                                                                                                       delete(Ext.getCmp("idtmcode").getStore().baseParams["provcode"]);
                                                                                                                                       delete(Ext.getCmp("idtmcode").getStore().baseParams["amcode"]);
                                                                                                                                       if (Ext.getCmp("idtmcode").getStore().lastOptions && Ext.getCmp("idtmcode").getStore().lastOptions.params) {
                                                                                                                                                delete(Ext.getCmp("idtmcode").getStore().lastOptions.params["provcode"]);
                                                                                                                                                delete(Ext.getCmp("idtmcode").getStore().lastOptions.params["amcode"]);
                                                                                                                                       }
                                                                                                                                       if (combo.getValue() != ""){
                                                                                                                                                Ext.getCmp("idtmcode").clearValue();
                                                                                                                                                Ext.getCmp("idprovcode").enable();                                                                                          
                                                                                                                                                Ext.getCmp("idamcode").enable();
                                                                                                                                                Ext.getCmp("idsdcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdcode").disable();
                                                                                                                                                Ext.getCmp("idsdtcode").clearValue(); 
                                                                                                                                                Ext.getCmp("idtmcode").enable();
                                                                                                                                                Ext.getCmp("idtmcode").getStore().baseParams = {
                                                                                                                                                         provcode: Ext.getCmp("idprovcode").getValue()
                                                                                                                                                         ,amcode: combo.getValue()
                                                                                                                                                }
                                                                                                                                                Ext.getCmp("idtmcode").getStore().load({ params: { start: 0, limit: 10} });
                                                                                                                                       }
                                                                                                                              }
                                                                                                                              ,blur: function(combo){
                                                                                                                                       if (combo.getValue() == combo.getRawValue()){
                                                                                                                                                combo.clearValue();
                                                                                                                                                delete(Ext.getCmp("idtmcode").getStore().baseParams["provcode"]);
                                                                                                                                                delete(Ext.getCmp("idtmcode").getStore().baseParams["amcode"]);
                                                                                                                                                if (Ext.getCmp("idtmcode").getStore().lastOptions && Ext.getCmp("idtmcode").getStore().lastOptions.params) {
                                                                                                                                                         delete(Ext.getCmp("idtmcode").getStore().lastOptions.params["provcode"]);
                                                                                                                                                         delete(Ext.getCmp("idtmcode").getStore().lastOptions.params["amcode"]);
                                                                                                                                                }
                                                                                                                                                Ext.getCmp("idtmcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdtcode").clearValue();
                                                                                                                                                Ext.getCmp("idprovcode").enable();                                                                                          
                                                                                                                                                Ext.getCmp("idamcode").enable();
                                                                                                                                                Ext.getCmp("idsdcode").disable();
                                                                                                                                                Ext.getCmp("idtmcode").disable();
                                                                                                                                       }                                                                                                                                    
                                                                                                                              }                                                                                                                              
                                                                                                                     }
                                                                                                            })
                                                                                                            ,new Ext.ux.form.PisComboBox({//หน่วยงาน
                                                                                                                     fieldLabel: 'หน่วยงาน'
                                                                                                                     ,disabled: true
                                                                                                                     ,hiddenName: 'sdcode'
                                                                                                                     ,id: 'idsdcode'
                                                                                                                     ,listWidth: 400
                                                                                                                     ,valueField: 'sdcode'
                                                                                                                     ,displayField: 'subdeptname'
                                                                                                                     ,urlStore: pre_url + '/code/csubdept'
                                                                                                                     ,fieldStore: ['sdcode', 'subdeptname']
                                                                                                                     ,anchor: "100%"
                                                                                                                     
                                                                                                            })
                                                                                                   ]
                                                                                          },{
                                                                                                      width: 300
                                                                                                      ,layout: "form"
                                                                                                      ,items: [
                                                                                                            new Ext.ux.form.PisComboBox({//ตำบล
                                                                                                                     fieldLabel: 'ตำบล'
                                                                                                                    ,disabled: true
                                                                                                                    ,hiddenName: 'tmcode'
                                                                                                                    ,id: 'idtmcode'
                                                                                                                    ,valueField: 'tmcode'
                                                                                                                    ,displayField: 'tmname'
                                                                                                                    ,urlStore: pre_url + '/code/ctumbon'
                                                                                                                    ,fieldStore: ['tmcode', 'tmname']
                                                                                                                     ,anchor: "100%"
                                                                                                                     ,listeners: {
                                                                                                                              select: function( combo,record,  index ) {
                                                                                                                                       if (combo.getValue() != ""){
                                                                                                                                                Ext.getCmp("idprovcode").enable();											
                                                                                                                                                Ext.getCmp("idamcode").enable();
                                                                                                                                                Ext.getCmp("idsdcode").clearValue();
                                                                                                                                                Ext.getCmp("idsdcode").disable();
                                                                                                                                                Ext.getCmp("idsdtcode").clearValue(); 
                                                                                                                                                Ext.getCmp("idtmcode").enable();											
                                                                                                                                       }
                                                                                                                              }                                                                                                                
                                                                                                                     }
                                                                                                            })
                                                                                                            ,new Ext.form.ComboBox({//สถานะตำแหน่ง
                                                                                                                     fieldLabel: 'สถานะตำแหน่ง'
                                                                                                                     ,hiddenName: 'status_pos'
                                                                                                                     ,id: "idstatus_pos"
                                                                                                                     ,store: new Ext.data.SimpleStore({
                                                                                                                              fields: ['id', 'type']
                                                                                                                              ,data: [['0', 'ว่าง'],['1', 'มีคนครองตำแหน่ง']]
                                                                                                                     })
                                                                                                                     ,valueField: 'id'
                                                                                                                     ,displayField: 'type'
                                                                                                                     ,typeAhead: true
                                                                                                                     ,mode: 'local'
                                                                                                                     ,triggerAction: 'all'
                                                                                                                     ,emptyText: 'Select ...'
                                                                                                                     ,selectOnFocus: true
                                                                                                                     ,anchor: "100%"
                                                                                                                     
                                                                                                            })
                                                                                                   ]
                                                                                          }
                                                                                 ]
                                                                        }
                                                               ]
                                                               ,buttons: [
                                                                        {
                                                                                 text: "ค้นหา"
                                                                                 ,handler: function(){
                                                                                          delete(j18GridStore.baseParams["provcode"]);
                                                                                          delete(j18GridStore.baseParams["sdtcode"]);
                                                                                          delete(j18GridStore.baseParams["amcode"]);
                                                                                          delete(j18GridStore.baseParams["sdcode"]);
                                                                                          delete(j18GridStore.baseParams["tmcode"]);
                                                                                          delete(j18GridStore.baseParams["status"]);
                                                                                          if (j18GridStore.lastOptions && j18GridStore.lastOptions.params) {						
                                                                                                   delete(j18GridStore.lastOptions.params["provcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["sdtcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["amcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["sdcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["tmcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["status"]);
                                                                                          }
                                                                                          j18GridStore.baseParams = {
                                                                                                   provcode:  Ext.getCmp("idprovcode").getValue()
                                                                                                   ,sdtcode:  Ext.getCmp("idsdtcode").getValue()
                                                                                                   ,amcode:  Ext.getCmp("idamcode").getValue()
                                                                                                   ,sdcode:  Ext.getCmp("idsdcode").getValue()
                                                                                                   ,tmcode:  Ext.getCmp("idtmcode").getValue()
                                                                                                   ,status:  Ext.getCmp("idstatus_pos").getValue()
                                                                                          }
                                                                                          if (j18GridStore.lastOptions && j18GridStore.lastOptions.params && j18GridStore.lastOptions.params.query){
                                                                                                  j18GridStore.load({ params: {
                                                                                                            start: 0
                                                                                                            ,limit: 20
                                                                                                            ,fields: j18GridStore.lastOptions.params.fields
                                                                                                            ,query: j18GridStore.lastOptions.params.query
                                                                                                   }}); 
                                                                                          }
                                                                                          else{
                                                                                                   j18GridStore.load({ params: { start: 0, limit: 20} });
                                                                                          }
                                                                                 }
                                                                        },{
                                                                                 text: "ยกเลิก"
                                                                                 ,handler: function(){                                                                                          
                                                                                          delete(j18GridStore.baseParams["provcode"]);
                                                                                          delete(j18GridStore.baseParams["sdtcode"]);
                                                                                          delete(j18GridStore.baseParams["amcode"]);
                                                                                          delete(j18GridStore.baseParams["sdcode"]);
                                                                                          delete(j18GridStore.baseParams["tmcode"]);
                                                                                          delete(j18GridStore.baseParams["status"]);
                                                                                          if (j18GridStore.lastOptions && j18GridStore.lastOptions.params) {						
                                                                                                   delete(j18GridStore.lastOptions.params["provcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["sdtcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["amcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["sdcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["tmcode"]);						
                                                                                                   delete(j18GridStore.lastOptions.params["status"]);
                                                                                          }
                                                                                          Ext.getCmp("idprovcode").clearValue();
                                                                                          Ext.getCmp("idsdtcode").clearValue();
                                                                                          Ext.getCmp("idamcode").clearValue();
                                                                                          Ext.getCmp("idsdcode").clearValue();
                                                                                          Ext.getCmp("idtmcode").clearValue();
                                                                                          Ext.getCmp("idstatus_pos").clearValue();
                                                                                          j18GridStore.reload();
                                                                                 }
                                                                        }	
                                                               ]
                                                      }      
                                             ]
                                    }
                           ]
                  }
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         } 
});

/***********************************************************************/
//search j18
/************************************************************************/
var j18Search = new Ext.ux.grid.Search({
         iconCls: 'search'
         ,minChars: 3
         ,autoFocus: true
         ,position: "top"
         ,width: 200
         ,disableIndexes: ["status"]
});
var j18Fields = [
         {name: "id", type: "string"}
         ,{name: "posid",type:"init"}
         ,{name: "status",type:"string"}
         ,{name: "posname",type:"string"}
         ,{name: "cname",type:"string"}
         ,{name: "salary",type:"string"}
         ,{name: "subdeptname",type:"string"}
         ,{name: "deptname",type:"string"}
];

var j18Cols = [
         {
                 header: "#"
                 ,width: 80
                 ,renderer: rowNumberer.createDelegate(this)
                 ,sortable: false
         }		
         ,{header: "ตำแหน่งเลขที่",width: 100, sortable: false, dataIndex: 'posid'	}
         ,{header: "สถานะตำแหน่ง",width:150,sortable:false,dataIndex:"status"}
         ,{header: "ตำแหน่งสายงาน",width: 250, sortable: false, dataIndex: 'posname'	}
         ,{header: "ระดับ",width: 250, sortable: false, dataIndex: 'cname'	}
         ,{header: "เงินเดือน",width: 80, sortable: false, dataIndex: 'salary'}
         ,{header: "หน่วยงาน",width: 200, sortable: false, dataIndex: 'subdeptname'}
         ,{header: "กรม",width: 200, sortable: false, dataIndex: 'deptname'}
];

var j18GridStore = new Ext.data.JsonStore({
         url: pre_url + "/info_pis_j18/read"
         ,root: "records"
         ,autoLoad: false
         ,totalProperty: 'totalCount'
         ,fields: j18Fields
         ,idProperty: 'posid'
});

var j18Grid = new Ext.grid.GridPanel({
         region: 'center'
         ,split: true
         ,store: j18GridStore
         ,columns: j18Cols
         ,stripeRows: true
         ,loadMask: {msg:'Loading...'}
         ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
         ,plugins: [j18Search]
         ,bbar: new Ext.PagingToolbar({
                  pageSize: 20
                  ,autoWidth: true
                  ,store: j18GridStore
                  ,displayInfo: true
                  ,displayMsg: 'Displaying {0} - {1} of {2}'
                  ,emptyMsg: "Not found"
         })
         ,tbar: [
                 {
                           text: "เพิ่ม"
                           ,iconCls: "table-add"
                           ,handler: function(){
                                    j18Form_url = pre_url + "/info_pis_j18/create"
                                    loadMask.show();                                    
                                    panelJ18.getLayout().setActiveItem(j18Form);
                                    j18Form.getForm().reset();
                                    Ext.getCmp("fname_lname").setValue("ว่าง")
                                    loadMask.hide();
                                    setWorkPlace();
                           }
                 }
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         } 
});

j18Grid.on('rowdblclick', function(grid, rowIndex, e ) {
         searchEditJ18(grid.getSelectionModel().getSelected().data);
});

function searchEditJ18(data_select){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_pis_j18/search_edit"
                  ,params: {
                           posid: data_select.posid
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           if (obj.success){                                    
                                    tab_personel.getActiveTab().setTitle("ข้อมูลตำแหน่ง(จ.18) ( " +obj.data.pisj18.fname_lname + " )")
                                    data_personel_id = data_select.id;
                                    j18Form_url = pre_url + "/info_pis_j18/edit"
                                    panelJ18.getLayout().setActiveItem(j18Form);
                                    j18Form.getForm().reset();
                                    setReadOnlyWorkPlace();
                                    Ext.getCmp("posid").setValue(obj.data.pisj18.posid);
                                    Ext.getCmp("fname_lname").setValue(obj.data.pisj18.fname_lname);
                                    Ext.getCmp("subdept_show").setValue(obj.data.pisj18.subdept_show);
                                    Ext.getCmp("pisj18[posid]").setValue(obj.data.pisj18.posid);
                                    Ext.getCmp("pisj18[salary]").setValue(obj.data.pisj18.salary);
                                    Ext.getCmp("pisj18[lastsal]").setValue(obj.data.pisj18.lastsal);
                                    Ext.getCmp("pisj18[nowsal]").setValue(obj.data.pisj18.nowsal);                                    
                                    Ext.getCmp("pisj18[lastsalasb]").setValue(obj.data.pisj18.lastsalasb);
                                    Ext.getCmp("pisj18[nowsalasb]").setValue(obj.data.pisj18.nowsalasb);
                                    Ext.getCmp("pisj18[octsalary]").setValue(obj.data.pisj18.octsalary);
                                    Ext.getCmp("pisj18[aprsalary]").setValue(obj.data.pisj18.aprsalary);
                                    Ext.getCmp("pisj18[posmny]").setValue(obj.data.pisj18.posmny);
                                    Ext.getCmp("pisj18[bkdmny]").setValue(obj.data.pisj18.bkdmny);
                                    Ext.getCmp("pisj18[asbdate]").setValue(to_date_app(obj.data.pisj18.asbdate));
                                    Ext.getCmp("pisj18[emptydate]").setValue(to_date_app(obj.data.pisj18.emptydate));
                                    Ext.getCmp("pisj18[rem]").setValue(obj.data.pisj18.rem);
                                    Ext.getCmp("pisj18[rem2]").setValue(obj.data.pisj18.rem2);
                                    Ext.getCmp("pisj18[sdcode]").setValue(obj.data.pisj18.sdcode);
                                    //pisj18[poscode]
                                    Ext.getCmp("pisj18[poscode]").getStore().load({
                                             params: {
                                                      poscode: obj.data.pisj18.poscode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[poscode]").setValue(obj.data.pisj18.poscode);
                                             }
                                    });
                                    // pisj18[c]
                                    Ext.getCmp("pisj18[c]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.c
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[c]").setValue(obj.data.pisj18.c);
                                             }
                                    });
                                    // pisj18[incode]
                                    Ext.getCmp("pisj18[incode]").getStore().load({
                                             params: {
                                                      incode: obj.data.pisj18.incode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[incode]").setValue(obj.data.pisj18.incode);
                                             }
                                    });
                                    // pisj18[ptcode]
                                    Ext.getCmp("pisj18[ptcode]").getStore().load({
                                             params: {
                                                      ptcode: obj.data.pisj18.ptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[ptcode]").setValue(obj.data.pisj18.ptcode);
                                             }
                                    });
                                    // pisj18[excode]
                                    Ext.getCmp("pisj18[excode]").getStore().load({
                                             params: {
                                                      excode: obj.data.pisj18.excode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[excode]").setValue(obj.data.pisj18.excode);
                                             }
                                    });
                                    // pisj18[epcode]
                                    Ext.getCmp("pisj18[epcode]").getStore().load({
                                             params: {
                                                      epcode: obj.data.pisj18.epcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[epcode]").setValue(obj.data.pisj18.epcode);
                                             }
                                    });
                                    // pisj18[mincode]
                                    Ext.getCmp("pisj18[mincode]").getStore().load({
                                             params: {
                                                      mcode: obj.data.pisj18.mincode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[mincode]").setValue(obj.data.pisj18.mincode);
                                             }
                                    });
                                    // pisj18[deptcode]
                                    Ext.getCmp("pisj18[deptcode]").getStore().load({
                                             params: {
                                                      deptcode: obj.data.pisj18.deptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[deptcode]").setValue(obj.data.pisj18.deptcode);
                                             }
                                    });
                                    // pisj18[dcode]
                                    Ext.getCmp("pisj18[dcode]").getStore().load({
                                             params: {
                                                      dcode: obj.data.pisj18.dcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[dcode]").setValue(obj.data.pisj18.dcode);
                                             }
                                    });
                                    // pisj18[seccode]
                                    Ext.getCmp("pisj18[seccode]").getStore().load({
                                             params: {
                                                      seccode: obj.data.pisj18.seccode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[seccode]").setValue(obj.data.pisj18.seccode);
                                             }
                                    });
                                    // pisj18[jobcode]
                                    Ext.getCmp("pisj18[jobcode]").getStore().load({
                                             params: {
                                                      jobcode: obj.data.pisj18.jobcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[jobcode]").setValue(obj.data.pisj18.jobcode);
                                             }
                                    });
                                    // pisj18[lastc]
                                    Ext.getCmp("pisj18[lastc]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.lastc
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[lastc]").setValue(obj.data.pisj18.lastc);
                                             }
                                    });
                                    // pisj18[nowc]
                                    Ext.getCmp("pisj18[nowc]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.nowc
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[nowc]").setValue(obj.data.pisj18.nowc);
                                             }
                                    });
                                    // pisj18[octc]
                                    Ext.getCmp("pisj18[octc]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.octc
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[octc]").setValue(obj.data.pisj18.octc);
                                             }
                                    });
                                    // pisj18[lastcasb]
                                    Ext.getCmp("pisj18[lastcasb]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.lastcasb
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[lastcasb]").setValue(obj.data.pisj18.lastcasb);
                                             }
                                    });
                                    // pisj18[nowcasb]
                                    Ext.getCmp("pisj18[nowcasb]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.nowcasb
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[nowcasb]").setValue(obj.data.pisj18.nowcasb);
                                             }
                                    });
                                    // pisj18[aprc]
                                    Ext.getCmp("pisj18[aprc]").getStore().load({
                                             params: {
                                                      ccode: obj.data.pisj18.aprc
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[aprc]").setValue(obj.data.pisj18.aprc);
                                             }
                                    });
                                    // pisj18[pcdcode]
                                    Ext.getCmp("pisj18[pcdcode]").getStore().load({
                                             params: {
                                                      pcdcode: obj.data.pisj18.pcdcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[pcdcode]").setValue(obj.data.pisj18.pcdcode);
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

function searchJ18ById(personel_id){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_personal/search_id"
                  ,params: {
                           id: personel_id
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           if (obj.data.length != 0){
                                    panelJ18.getLayout().setActiveItem(j18Form); 
                                    searchEditJ18(obj.data[0]);                                     
                           }
                           else{
                                    data_personel_id = "";
                                    panelJ18.getLayout().setActiveItem(panelJ18First);
                                    loadMask.hide();
                           }
                  }
                  ,failure: function(response,opts){
                           Ext.Msg.alert("สถานะ",response.statusText);
                           loadMask.hide();
                  }
         });
}
/***********************************************************************/
//form j18
/************************************************************************/
var j18Form = new Ext.FormPanel({ 
         border: false
         ,labelWidth: 113
         ,autoScroll: true
         ,frame: true
         ,monitorValid: true
         ,bodyStyle: "padding:20px"
         ,labelAlign: "right"
         ,items: [
                  {
                           xtype: "hidden"
                           ,id: "posid"
                  }
                  ,{
                           xtype: "fieldset"
                           ,bodyStyle: "padding:10px"
                           ,width: 1000
                           ,layout: "form"
                           ,items: [
                                    {
                                             xtype: "textfield"
                                             ,fieldLabel: "ตำแหน่งเลขที่"
                                             ,id: "pisj18[posid]"
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "ตำแหน่งสายงาน"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                                               hiddenName: 'pisj18[poscode]'
                                                               ,id: 'pisj18[poscode]'
                                                               ,valueField: 'poscode'
                                                               ,displayField: 'posname'
                                                               ,urlStore: pre_url + '/code/cposition'
                                                               ,fieldStore: ['poscode', 'posname']
                                                               ,width: 250
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ระดับ:"
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//ระดับ
                                                               hiddenName: 'pisj18[c]'
                                                               ,id: 'pisj18[c]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 250
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "เงินเดือน:"
                                                      }
                                                      ,{
                                                               xtype: "numberfield"
                                                               ,fieldLabel: "เงินเดือน"
                                                               ,id: "pisj18[salary]"
                                                       }
                                             ]
                                    }
                                    ,{
                                             xtype: "textfield"	
                                             ,fieldLabel: "ชื่อผู้ครองตำแหน่ง"
                                             ,id: "fname_lname"
                                             ,anchor: "100%"
                                             ,readOnly: true
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "ช่วงระดับ"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//ช่วงระดับ
                                                               hiddenName: 'pisj18[incode]'
                                                               ,id: 'pisj18[incode]'
                                                               ,valueField: 'incode'
                                                               ,displayField: 'inname'
                                                               ,urlStore: pre_url + '/code/cinterval'
                                                               ,fieldStore: ['incode', 'inname']
                                                               ,width: 250
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align: right"
                                                               ,value: "ว./ว.ช/ชช.:"
                                                               ,width: 100
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                                               hiddenName: 'pisj18[ptcode]'
                                                               ,id: 'pisj18[ptcode]'
                                                               ,valueField: 'ptcode'
                                                               ,displayField: 'ptname'
                                                               ,urlStore: pre_url + '/code/cpostype'
                                                               ,fieldStore: ['ptcode', 'ptname']
                                                               ,width: 250
                                                      })
                                             ]
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "ตำแหน่งบริหาร"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                                               hiddenName: 'pisj18[excode]'
                                                               ,id: 'pisj18[excode]'
                                                               ,valueField: 'excode'
                                                               ,displayField: 'exname'
                                                               ,urlStore: pre_url + '/code/cexecutive'
                                                               ,fieldStore: ['excode', 'exname']
                                                               ,width: 250
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align: right"
                                                               ,value: "ความเชี่ยวชาญ:"
                                                               ,width: 100
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                                               hiddenName: 'pisj18[epcode]'
                                                               ,id: 'pisj18[epcode]'
                                                               ,valueField: 'epcode'
                                                               ,displayField: 'expert'
                                                               ,urlStore: pre_url + '/code/cexpert'
                                                               ,fieldStore: ['epcode', 'expert']
                                                               ,width: 250
                                                      })
                                             ]
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "กระทรวง"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//กระทรวง
                                                               hiddenName: 'pisj18[mincode]'
                                                               ,id: 'pisj18[mincode]'
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
                                                               hiddenName: 'pisj18[deptcode]'
                                                               ,id: 'pisj18[deptcode]'
                                                               ,valueField: 'deptcode'
                                                               ,displayField: 'deptname'
                                                               ,urlStore: pre_url + '/code/cdept'
                                                               ,fieldStore: ['deptcode', 'deptname']
                                                               ,width: 250
                                                      })
                                             ]
                                    }
                                    ,new Ext.ux.form.PisComboBox({//กอง
                                             hiddenName: 'pisj18[dcode]'
                                             ,id: 'pisj18[dcode]'
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
                                                               ,id: "pisj18[sdcode]"
                                                               ,width: 80
                                                               ,enableKeyEvents: (user_work_place.sdcode == undefined)? true : false
                                                               ,listeners: {
                                                                        keydown : function( el,e ){
                                                                                 Ext.getCmp("subdept_show").setValue("");
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
                                                                                                   Ext.getCmp("pisj18[sdcode]").setValue("");
                                                                                                   Ext.getCmp("subdept_show").setValue("");
                                                                                                }
                                                                                                else{
                                                                                                   Ext.getCmp("pisj18[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                   Ext.getCmp("subdept_show").setValue(obj.records[0].subdeptname);
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
                                                                                 if (Ext.getCmp("subdept_show").getValue() == ""){
                                                                                          Ext.getCmp("pisj18[sdcode]").setValue("");
                                                                                          Ext.getCmp("subdept_show").setValue("");    
                                                                                 }
                                                                        }
                                                                        
                                                               }
                                                      }
                                                      ,{
                                                               xtype: "textfield"
                                                               ,id: "subdept_show"
                                                               ,readOnly: true
                                                               ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:80%;"
                                                      }
                                                      ,{
                                                               xtype: "button"
                                                               ,id: "sdcode_button"
                                                               ,text: "..."
                                                               ,handler: function(){
                                                                        searchSubdept(Ext.getCmp("pisj18[sdcode]"),Ext.getCmp("subdept_show"));
                                                               }
                                                      }
                                             ]
                                    }
                                    ,{
                                             xtype: "compositefield"
                                             ,fieldLabel: "ฝ่าย/กลุ่มงาน"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                                               hiddenName: 'pisj18[seccode]'
                                                               ,id: 'pisj18[seccode]'
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
                                                               hiddenName: 'pisj18[jobcode]'
                                                               ,id: 'pisj18[jobcode]'
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
                  },{
                           xtype: "fieldset"
                           ,bodyStyle: "padding:10px"
                           ,width: 1000
                           ,layout: "form"
                           ,items: [
                                    {
                                             xtype: "compositefield"
                                             ,fieldLabel: "ถือจ่ายปีก่อน ระดับ"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//ถือจ่ายปีก่อน ระดับ
                                                               hiddenName: 'pisj18[lastc]'
                                                               ,id: 'pisj18[lastc]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 200
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ชั้น:"
                                                      }
                                                      ,{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[lastsal]"
                                                               ,width: 50
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align:right"
                                                               ,width: 150
                                                               ,value: "ถือจ่ายปีปัจจุบัน ระดับ:"
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//1 ต.ค. ระดับ
                                                               hiddenName: 'pisj18[nowc]'
                                                               ,id: 'pisj18[nowc]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 200
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ชั้น:"
                                                      }
                                                      ,{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[nowsal]"
                                                               ,width: 50
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      }
                                             ]
                                    },{
                                             xtype: "compositefield"
                                             ,fieldLabel: "อาศัยเบิกปีก่อน ระดับ"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//อาศัยเบิกปีก่อน ระดับ
                                                               hiddenName: 'pisj18[lastcasb]'
                                                               ,id: 'pisj18[lastcasb]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 200
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ชั้น:"
                                                      },{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[lastsalasb]"
                                                               ,width: 50
                                                      },{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      },{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align:right"
                                                               ,width: 150
                                                               ,value: "อาศัยเบิกปีปัจจุบัน ระดับ:"
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//อาศัยเบิกปีปัจจุบัน ระดับ
                                                               hiddenName: 'pisj18[nowcasb]'
                                                               ,id: 'pisj18[nowcasb]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 200
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ชั้น:"
                                                      }
                                                      ,{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[nowsalasb]"
                                                               ,width: 50
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      }
                                             ]
                                    },{
                                             xtype: "compositefield"
                                             ,fieldLabel: "1 ต.ค. ระดับ"
                                             ,items: [
                                                      new Ext.ux.form.PisComboBox({//1 ต.ค. ระดับ
                                                               hiddenName: 'pisj18[octc]'
                                                               ,id: 'pisj18[octc]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 200
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ชั้น:"
                                                      },{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[octsalary]"
                                                               ,width: 50
                                                      },{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      },{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align:right"
                                                               ,width: 150
                                                               ,value: "1 เม.ย. ระดับ:"
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//1 เม.ย. ระดับ
                                                               hiddenName: 'pisj18[aprc]'
                                                               ,id: 'pisj18[aprc]'
                                                               ,valueField: 'ccode'
                                                               ,displayField: 'cname'
                                                               ,urlStore: pre_url + '/code/cgrouplevel'
                                                               ,fieldStore: ['ccode', 'cname']
                                                               ,width: 200
                                                      })
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "ชั้น:"
                                                      }
                                                      ,{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[aprsalary]"
                                                               ,width: 50
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      }
                                             ]
                                    },{
                                             xtype: "compositefield"
                                             ,fieldLabel: "เงินประจำตำแหน่ง"
                                             ,items: [
                                                      {
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[posmny]"
                                                               ,width: 150
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align: right"
                                                               ,width: 100
                                                               ,value: "เบี้ยกันดาร:"
                                                      }
                                                      ,{
                                                               xtype: "numberfield"
                                                               ,id: "pisj18[bkdmny]"
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px"
                                                               ,value: "บาท"
                                                      }
                                                      ,{
                                                               xtype: "displayfield"
                                                               ,style: "padding: 4px;text-align: right"
                                                               ,width: 100
                                                               ,value: "เงื่อนไขตำแหน่ง:"
                                                      }
                                                      ,new Ext.ux.form.PisComboBox({//เงื่อนไขตำแหน่ง
                                                               hiddenName: 'pisj18[pcdcode]'
                                                               ,id: 'pisj18[pcdcode]'
                                                               ,valueField: 'pcdcode'
                                                               ,displayField: 'pcdname'
                                                               ,urlStore: pre_url + '/code/cposcondition'
                                                               ,fieldStore: ['pcdcode', 'pcdname']
                                                               ,width: 250
                                                      })
                                                      
                                             ]
                                    }
                                    ,{
                                         xtype: "datefield"
                                         ,fieldLabel: "วัน ก.พ. กำหนดตำแหน่ง"
                                         ,id: "pisj18[asbdate]"
                                         ,format: "d/m/Y"
                                    }
                                    ,{
                                         xtype: "datefield"
                                         ,fieldLabel: "วันที่ตำแหน่งว่าง"
                                         ,id: "pisj18[emptydate]"
                                         ,format: "d/m/Y"
                                    },{
                                             xtype: "textfield"
                                             ,id: "pisj18[rem]"
                                             ,fieldLabel: "หมายเหตุ1"
                                             ,anchor: "100%"
                                    }
                                    ,{
                                             xtype: "textfield"
                                             ,id: "pisj18[rem2]"
                                             ,fieldLabel: "หมายเหตุ2"
                                             ,anchor: "100%"
                                    }
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           } 
                  }
                  
         ]
         ,buttons:[
		  { 
                           text:'บันทึก'
                           ,formBind: true 
                           ,handler:function(){
                                    j18Form.getForm().submit(
                                    { 
                                           method:'POST'
                                           ,url: j18Form_url
                                           ,waitTitle:'Saving Data'
                                           ,waitMsg:'Sending data...'
                                           ,success:function(){		
                                                   Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                   if (btn == 'ok')
                                                                   {
                                                                        panelJ18.getLayout().setActiveItem(panelJ18First);
                                                                        j18GridStore.reload();
                                                                        j18Form.getForm().reset();
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
                                    data_personel_id = "";
                                    loadMask.show();
                                    panelJ18.getLayout().setActiveItem(panelJ18First);
                                    j18GridStore.reload();
                                    j18Form.getForm().reset();
                                    loadMask.hide();
                          }
                  }
	 ]
         ,listeners: {
                  deactivate : function( p ){
                           tab_personel.getActiveTab().setTitle("ข้อมูลตำแหน่ง(จ.18)")
                  } 
         }
});

/***********************************************************************/
//panel j18
/************************************************************************/
var panelJ18First = new Ext.Panel({
         layout: "border"
         ,items: [
                  panleSearchJ18
                  ,j18Grid
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         } 
});
var panelJ18 = new Ext.Panel({
         layout: "card"
         //,activeItem: 0
         ,layoutConfig: {
                  deferredRender: true
                  ,layoutOnCardChange: true
         }
         ,items: [
                  panelJ18First
                  ,j18Form
         ]
         ,listeners: {
                  afterrender: function(el){
                           el.doLayout();
                  }
         } 
});

