/********************************************************************/
/*Grid*/
/******************************************************************/    
var data_pis_trainningSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});
var data_pis_trainningFields = [
     ,{name: "id", type: "string"}
     ,{name: "sex", type: "string"}
     ,{name: "prefix", type: "string"}
     ,{name: "fname", type: "string"}
     ,{name: "lname", type: "string"}
     ,{name: "pid", type: "string"}
     ,{name: "birthdate", type: "string"}
     ,{name: "tel", type: "string"}
     ,{name: "name", type: "string"}
];

var data_pis_trainningCols = [
      {
               header: "#"
               ,width: 80
               ,renderer: rowNumberer.createDelegate(this)
               ,sortable: false
      }		
      ,{header: "คำนำหน้า",width: 70, sortable: false, dataIndex: 'prefix'}
      ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
      ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
      ,{header: "เลขบัตรประชาชน",width: 100, sortable: false, dataIndex: 'pid'}
      ,{header: "วันเกิด",width: 100, sortable: false, dataIndex: 'birthdate'}
      ,{header: "เพศ",width: 100, sortable: false, dataIndex: 'sex'}
      ,{header: "เบอร์โทรศัพท์",width: 100, sortable: false, dataIndex: 'tel'}
];

var data_pis_trainningGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_personal/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_pis_trainningFields
	,idProperty: 'id'
});

var data_pis_trainningGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_pis_trainningGridStore
	,columns: data_pis_trainningCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [data_pis_trainningSearch]
	,bbar: new Ext.PagingToolbar({
		pageSize: 20
		,autoWidth: true
		,store: data_pis_trainningGridStore
		,displayInfo: true
		,displayMsg	: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,tbar: ["&nbsp;"]
});
data_pis_trainningGrid.on('rowdblclick', function(grid, rowIndex, e ) {
    data_select = grid.getSelectionModel().getSelected().data;
    data_personel_id = data_select.id;
    searchEditTrainning(data_select);
});
function searchEditTrainning(data_select){
    tab_personel.getActiveTab().getLayout().setActiveItem(data_trainning_detailGrid);
    tab_personel.getActiveTab().setTitle("การประชุม/อบรม ( " +data_select.name+ " )")
    data_trainning_detailGridStore.baseParams = {
	    id: data_personel_id
    }
    data_trainning_detailGridStore.load({ params: { start: 0, limit: 20} });	
}
function searchTrainningById(personel_id){
      loadMask.show();
      Ext.Ajax.request({
	       url: pre_url + "/info_personal/search_id"
	       ,params: {
			id: personel_id
	       }
	       ,success: function(response,opts){
			obj = Ext.util.JSON.decode(response.responseText);
			 searchEditTrainning(obj.data[0]);
			 loadMask.hide();
	       }
	       ,failure: function(response,opts){
			Ext.Msg.alert("สถานะ",response.statusText);
			loadMask.hide();
	       }
      });
 }
/********************************************************************/
/*Grid  Detail*/
/******************************************************************/
var data_trainning_detailFields = [
     {name: "id", type: "string"}
     ,{name: "tno", type: "int"}
     ,{name: "begindate", type: "string"}
     ,{name: "enddate", type: "string"}
     ,{name: "coname", type: "string"}         
     ,{name: "cource", type: "string"}
     ,{name: "institute", type: "string"}		
];
    
var data_trainning_detailCols = [
	{header: "ครั้งที่",width: 80, sortable: false, dataIndex: 'tno'}
	,{header: "ตั้งแต่วันที่",width: 150, sortable: false, dataIndex: 'begindate'}
	,{header: "ถึงวันที่",width: 150, sortable: false, dataIndex: 'enddate'}
	,{header: "หลักสูตร",width: 150, sortable: false, dataIndex: 'cource'}
	,{header: "สถาบัน",width: 180, sortable: false, dataIndex: 'institute'}
	,{header: "ประเทศ",width: 150, sortable: false, dataIndex: 'coname'}
];

var data_trainning_detailGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_pis_trainning/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_trainning_detailFields
	,idProperty: 'tno'
});

var data_trainning_detailGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_trainning_detailGridStore
	,columns: data_trainning_detailCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: []
	,bbar: new Ext.PagingToolbar({
	      pageSize: 20
	      ,autoWidth: true
	      ,store: data_trainning_detailGridStore
	      ,displayInfo: true
	      ,displayMsg: 'Displaying {0} - {1} of {2}'
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
						,url: pre_url + '/info_pis_trainning/create'
						,frame: true
						,monitorValid: true
						,bodyStyle: "padding:10px"
						,items:[
							{
								xtype: "hidden"
								,id: "pistrainning[id]"
								,value: data_personel_id
							}
							,{
								xtype: "textfield"
								,id: "pistrainning[cource]"
								,fieldLabel: "หลักสูตร"
								,anchor: "95%"
							}
							,{
								xtype: "datefield"
								,id: "pistrainning[begindate]"
								,fieldLabel: "ตั้งแต่วันที่"
								,format: "d/m/Y"
							}
							,{
								xtype: "datefield"
								,id: "pistrainning[enddate]"
								,fieldLabel: "ถึงวันที่"
								,format: "d/m/Y"
							}
							,{
								xtype: "textfield"
								,id: "pistrainning[institute]"
								,fieldLabel: "สถาบัน"
								,anchor: "100%"
								,anchor: "95%"
							}
							,new Ext.ux.form.PisComboBox({//ประเทศ
							     fieldLabel: 'ประเทศ'
							     ,id: 'pistrainning[cocode]'
							     ,hiddenName:'pistrainning[cocode]'
							     ,valueField: 'cocode'
							     ,displayField: 'coname'
							     ,urlStore: pre_url + '/code/ccountry'
							     ,fieldStore: ['cocode', 'coname']
							     ,anchor: "95%"
							})
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
														data_trainning_detailGridStore.reload();
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
						title: 'เพิ่ม/แก้ไข การประชุม/อบรม'
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
							url: pre_url + '/info_pis_trainning/delete' , 
							params: { 
								id: data_trainning_detailGrid.getSelectionModel().getSelections()[0].data.id
								,tno: data_trainning_detailGrid.getSelectionModel().getSelections()[0].data.tno
								,random: Math.random()
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
												data_trainning_detailGridStore.reload();
											}
										}
									); 
								}
							}
						});	
					}//end if (btn == 'yes')
				});		
			}
		},"-",{
			text: "ปิด"
			,iconCls: "delete"
			,handler: function	(){                  
				tab_personel.getActiveTab().setTitle("การประชุม/อบรม");
				data_personel_id = "";
				tab_personel.getActiveTab().getLayout().setActiveItem(data_pis_trainningGrid); 
			}
		}
		    ]
});

data_trainning_detailGrid.getSelectionModel().on('selectionchange', function(sm){
     data_trainning_detailGrid.removeBtn.setDisabled(sm.getCount() < 1);       
 });
data_trainning_detailGrid.on('rowdblclick', function(grid, rowIndex, e ) {
     record = grid.getSelectionModel().getSelected();
     Ext.Ajax.request({
	     url: pre_url + '/info_pis_trainning/search_edit'
	     ,params: {
		     id: record.data.id
		     ,tno: record.data.tno
	     }
	     ,success: function(response, opts) {
			var obj = Ext.decode(response.responseText);
			if(!form){
				data = obj.data.pistrainning;
				var form = new Ext.FormPanel({ 
					labelWidth: 100
					,autoScroll: true
					,url: pre_url + '/info_pis_trainning/edit'
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
							,id: "tno"
							,value: data.tno
						}
						,{
							xtype: "textfield"
							,id: "pistrainning[cource]"
							,fieldLabel: "หลักสูตร"
							,anchor: "95%"
							,value: data.cource
						}
						,{
							xtype: "datefield"
							,id: "pistrainning[begindate]"
							,fieldLabel: "ตั้งแต่วันที่"
							,format: "d/m/Y"
							,value: to_date_app(data.begindate)
						}
						,{
							xtype: "datefield"
							,id: "pistrainning[enddate]"
							,fieldLabel: "ถึงวันที่"
							,format: "d/m/Y"
							,value: to_date_app(data.enddate)
						}
						,{
							xtype: "textfield"
							,id: "pistrainning[institute]"
							,fieldLabel: "สถาบัน"
							,anchor: "100%"
							,anchor: "95%"
							,value: data.institute
						}
						,new Ext.ux.form.PisComboBox({//ประเทศ
						     fieldLabel: 'ประเทศ'
						     ,id: 'pistrainning[cocode]'
						     ,hiddenName:'pistrainning[cocode]'
						     ,valueField: 'cocode'
						     ,displayField: 'coname'
						     ,urlStore: pre_url + '/code/ccountry'
						     ,fieldStore: ['cocode', 'coname']
						     ,anchor: "95%"
						})
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
													data_trainning_detailGridStore.reload();
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
					title: 'เพิ่ม/แก้ไข การประชุม/อบรม'
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
			Ext.getCmp("pistrainning[cocode]").getStore().load({
				params: {
					 cocode: data.cocode
					 ,start: 0
					 ,limit: 10
				}
				,callback :function(){
					 Ext.getCmp("pistrainning[cocode]").setValue(data.cocode);
					 loadMask.hide();
				}
			});
	     }
	     ,failure: function(response, opts) {
		     Ext.Msg.alert("สถานะ", response.statusText);
	     }
     });
});
