/********************************************************************/
/* Grid */
/******************************************************************/   
var data_pis_punishSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});
var data_pis_punishFields = [
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

var data_pis_punishCols = [
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

var data_pis_punishGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_personal/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_pis_punishFields
	,idProperty: 'id'
});

var data_pis_punishGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_pis_punishGridStore
	,columns: data_pis_punishCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [data_pis_punishSearch]
	,bbar: new Ext.PagingToolbar({
			pageSize: 20
			,autoWidth: true
			,store: data_pis_punishGridStore
			,displayInfo: true
			,displayMsg	: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,tbar: ["&nbsp;"]
});
data_pis_punishGrid.on('rowdblclick', function(grid, rowIndex, e ) {
    data_select = grid.getSelectionModel().getSelected().data
    data_personel_id = data_select.id;
    searchEditPunish(data_select);
});
function searchEditPunish(data_select){
     tab_personel.getActiveTab().getLayout().setActiveItem(data_punish_detailGrid);
     tab_personel.getActiveTab().setTitle("โทษทางวินัย ( " +data_select.name+ " )");
     data_punish_detailGridStore.baseParams = {
	     id: data_personel_id
     };
     data_punish_detailGridStore.load({ params: { start: 0, limit: 20} }); 	
}
function searchPunishById(personel_id){
      loadMask.show();
      Ext.Ajax.request({
	       url: pre_url + "/info_personal/search_id"
	       ,params: {
			id: personel_id
	       }
	       ,success: function(response,opts){
			obj = Ext.util.JSON.decode(response.responseText);
			 searchEditPunish(obj.data[0]);
			 loadMask.hide();
	       }
	       ,failure: function(response,opts){
			Ext.Msg.alert("สถานะ",response.statusText);
			loadMask.hide();
	       }
      });
 }
/********************************************************************/
/* Grid  Detail */
/******************************************************************/
var data_punish_detailFields = [
     {name: "id", type: "string"}
     ,{name: "idp", type: "int"}
     ,{name: "forcedate", type: "string"}
     ,{name: "pnname", type: "string"}
     ,{name: "cmdno", type: "string"}
];
    
var data_punish_detailCols = [
     {
	      header: "#"
	      ,width: 30
	      ,renderer: rowNumberer.createDelegate(this)
	      ,sortable: false
     }		
     ,{header: "วันที่",width: 150, sortable: false, dataIndex: 'forcedate'}
     ,{header: "โทษที่ได้รับ/กรณี",width: 150, sortable: false, dataIndex: 'pnname'}
     ,{header: "เอกสารอ้างอิง",width: 150, sortable: false, dataIndex: 'cmdno'}
];

var data_punish_detailGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_pis_punish/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_punish_detailFields
	,idProperty: 'idp'
});

var data_punish_detailGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_punish_detailGridStore
	,columns: data_punish_detailCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: []
		     ,bbar: new Ext.PagingToolbar({
			pageSize: 20
			,autoWidth: true
			,store: data_punish_detailGridStore
			,displayInfo: true
			,displayMsg	: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,tbar: [
			    {
				    text: "	เพิ่ม"
				    ,iconCls: "table-add"
				    ,handler: function (){
					if(!form){
						var form = new Ext.FormPanel({ 
							labelWidth: 100
							,autoScroll: true
							,url: pre_url + '/info_pis_punish/create'
							,frame: true
							,monitorValid: true
							,bodyStyle: "padding:10px"
							,items:[
								{
									xtype: "hidden"
									,id: "pispunish[id]"
									,value: data_personel_id
								}
								,new Ext.ux.form.PisComboBox({//โทษที่ได้รับ
									fieldLabel: 'โทษที่ได้รับ'   
									,hiddenName: 'pispunish[pncode]'
									,id: 'pispunish[pncode]'
									,valueField: 'pncode'
									,displayField: 'pnname'
									,urlStore: pre_url + '/code/cpunish'
									,fieldStore: ['pncode', 'pnname']
									,anchor: "90%"
									     												   
								 })
								,{
									xtype: "datefield"
									,id: "pispunish[forcedate]"
									,fieldLabel: "วันที่"
									,format: "d/m/Y"
								},{
									xtype: "textfield"
									,id: "pispunish[description]"
									,fieldLabel: "รายละเอียด"
									,anchor: "100%"
								},{
									xtype: "textfield"
									,id: "pispunish[cmdno]"
									,fieldLabel: "เอกสารอ้างอิง"
									,anchor: "100%"
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
															data_punish_detailGridStore.reload();
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
									,handler: function(){
										win.close();
									}
								}
							] 
						});
					}//end if form
					if(!win){
						var win = new Ext.Window({
							title: 'เพิ่ม/แก้ไข โทษทางวินัย'
							,width: 600
							,height: 300
							,closable: true
							,resizable: false
							,plain: true
							,border: false
							,draggable: true 
							,modal: true
							,layout: "fit"
							,items: [form]
						});
					}
					win.show();
					win.center();
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
						    if (btn == 'yes'){				
							    loadMask.show();
							    Ext.Ajax.request({
								    url: pre_url + '/info_pis_punish/delete' , 
								    params: { 
									    id: data_punish_detailGrid.getSelectionModel().getSelections()[0].data.id
									    ,forcedate: data_punish_detailGrid.getSelectionModel().getSelections()[0].data.forcedate
								    },	
								    failure: function ( result, request) { 
									    loadMask.hide();
									    Ext.MessageBox.alert('สถานะ', "Error: "+result.responseText); 
								    },
								    success: function ( result, request ) { 
									    loadMask.hide();
									    var obj = Ext.util.JSON.decode(result.responseText); 
									    if (obj.success == false){
										    Ext.MessageBox.alert('สถานะ', 'ไม่สามารถลบได้ <br> Error: ' + obj.msg); 
									    }
									    else if (obj.success == true){
										    Ext.MessageBox.alert('สถานะ', 'ลบเสร็จเรียบร้อย',function(btn, text){
												    if (btn == 'ok'){
													    data_punish_detailGridStore.reload();
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
				    ,handler: function	(){              
					    tab_personel.getActiveTab().setTitle("โทษทางวินัย");
					    data_personel_id = "";
					    tab_personel.getActiveTab().getLayout().setActiveItem(data_pis_punishGrid); 
				    }
			    }
		    ]
});

data_punish_detailGrid.getSelectionModel().on('selectionchange', function(sm){
     data_punish_detailGrid.removeBtn.setDisabled(sm.getCount() < 1);       
});
data_punish_detailGrid.on('rowdblclick', function(grid, rowIndex, e ) {
     record = grid.getSelectionModel().getSelected();
     loadMask.show();
     Ext.Ajax.request({
	     url: pre_url + '/info_pis_punish/search_edit'
	     ,params: {
		     id: data_personel_id
		     ,forcedate: record.data.forcedate
	     }
	     ,success: function(response, opts) {
			var obj = Ext.decode(response.responseText);
			if(obj.success){
				data = obj.data.pispunish;
				if(!form){
					var form = new Ext.FormPanel({ 
						labelWidth: 100
						,autoScroll: true
						,url: pre_url + '/info_pis_punish/edit'
						,frame: true
						,monitorValid: true
						,bodyStyle: "padding:10px"
						,items:[
							{
								xtype: "hidden"
								,id: "id"
								,value: data_personel_id
							}
							,{
								xtype: "hidden"
								,id: "forcedate"
								,value: data.forcedate
							}
							,new Ext.ux.form.PisComboBox({//โทษที่ได้รับ
								fieldLabel: 'โทษที่ได้รับ'   
								,hiddenName: 'pispunish[pncode]'
								,id: 'pispunish[pncode]'
								,valueField: 'pncode'
								,displayField: 'pnname'
								,urlStore: pre_url + '/code/cpunish'
								,fieldStore: ['pncode', 'pnname']
								,anchor: "90%"
																				   
							 })
							,{
								xtype: "datefield"
								,id: "pispunish[forcedate]"
								,fieldLabel: "วันที่"
								,format: "d/m/Y"
								,value: to_date_app(data.forcedate)
							},{
								xtype: "textfield"
								,id: "pispunish[description]"
								,fieldLabel: "รายละเอียด"
								,anchor: "100%"
								,value: data.description
							},{
								xtype: "textfield"
								,id: "pispunish[cmdno]"
								,fieldLabel: "เอกสารอ้างอิง"
								,anchor: "100%"
								,value: data.cmdno
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
														data_punish_detailGridStore.reload();
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
								,handler: function(){
									win.close();
								}
							}
						] 
					});
				}//end if form
				if(!win){
					var win = new Ext.Window({
						title: 'เพิ่ม/แก้ไข โทษทางวินัย'
						,width: 600
						,height: 300
						,closable: true
						,resizable: false
						,plain: true
						,border: false
						,draggable: true 
						,modal: true
						,layout: "fit"
						,items: [form]
					});
				}
				
				Ext.getCmp("pispunish[pncode]").getStore().load({
					params: {
						 pncode: obj.data.pispunish.pncode
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						Ext.getCmp("pispunish[pncode]").setValue(obj.data.pispunish.pncode);
						loadMask.hide();
						win.show();
						win.center();
						
					}
                                });
			
				
			}
	     }
	     ,failure: function(response, opts) {
		       loadMask.hide();  
		       Ext.Msg.alert("สถานะ", response.statusText);
	     }
     });         
});
