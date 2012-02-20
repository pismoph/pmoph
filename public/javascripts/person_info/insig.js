/********************************************************************/
/*Grid*/
/******************************************************************/    
var data_pis_insigSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});
var data_pis_insigFields = [
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

var data_pis_insigCols = [
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

var data_pis_insigGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_personal/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_pis_insigFields
	,idProperty: 'id'
});

var data_pis_insigGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_pis_insigGridStore
	,columns: data_pis_insigCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [data_pis_insigSearch]
	,bbar: new Ext.PagingToolbar({
			pageSize: 20
			,autoWidth: true
			,store: data_pis_insigGridStore
			,displayInfo: true
			,displayMsg	: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,tbar: ["&nbsp;"]
});

data_pis_insigGrid.on('rowdblclick', function(grid, rowIndex, e ) {
    data_select = grid.getSelectionModel().getSelected().data
    data_personel_id = data_select.id;
    searchEditInsig(data_select);
});
function searchEditInsig(data_select){
    tab_personel.getActiveTab().getLayout().setActiveItem(data_insig_detailGrid);
    tab_personel.getActiveTab().setTitle("ประวัติเครื่องราชย์ ( " +data_select.name+ " )")
    data_insig_detailGridStore.baseParams		= {
	    id: data_select.id
    }
    data_insig_detailGridStore.load({ params: { start: 0, limit: 20} });   
}

function searchInsigById(personel_id){
      loadMask.show();
      Ext.Ajax.request({
	       url: pre_url + "/info_personal/search_id"
	       ,params: {
			id: personel_id
	       }
	       ,success: function(response,opts){
			obj = Ext.util.JSON.decode(response.responseText);
			 searchEditInsig(obj.data[0]);
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
var data_insig_detailFields = [
    {name: "idp", type: "int"}
    ,{name: "id", type: "string"}
    ,{name: "dcname", type: "string"}
    ,{name: "dccode", type: "string"}
    ,{name: "dcyear", type: "string"}
    ,{name: "posname", type: "string"}
    ,{name: "cname", type: "string"}
    ,{name: "exname", type: "string"}
    ,{name: "ptname", type: "string"}
    ,{name: "expert", type: "string"}
];
    
var data_insig_detailCols = [
     {
		header: "#"
		,width: 80
		,renderer: rowNumberer.createDelegate(this)
		,sortable: false
     }		
     ,{header: "ชั้นเครื่องราชย์",width: 150, sortable: false, dataIndex: 'dcname'}
     ,{header: "ปีขอรับ",width: 150, sortable: false, dataIndex: 'dcyear'}
     ,{header: "ตำแหน่งสายงาน",width: 150, sortable: false, dataIndex: 'posname'}
     ,{header: "ระดับ",width: 150, sortable: false, dataIndex: 'cname'}
     ,{header: "ตำแหน่งบริหาร",width: 150, sortable: false, dataIndex: 'exname'}
     ,{header: "ว./วช./ชช.",width: 150, sortable: false, dataIndex: 'ptname'}
     ,{header: "ความเชี่ยวชาญ",width: 180, sortable: false, dataIndex: 'expert'}
];

var data_insig_detailGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_pis_insig/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_insig_detailFields
	,idProperty: 'idp'
});

var data_insig_detailGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_insig_detailGridStore
	,columns: data_insig_detailCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: []
	,bbar: new Ext.PagingToolbar({
	   pageSize: 20
	   ,autoWidth: true
	   ,store: data_insig_detailGridStore
	   ,displayInfo: true
	   ,displayMsg	: 'Displaying {0} - {1} of {2}'
	   ,emptyMsg: "Not found"
	})
	,tbar: [
		{
			text: "เพิ่ม"
			,iconCls: "table-add"
			,handler: function (){
				if(!form){
					var form = new Ext.FormPanel({ 
						labelWidth: 100
						,autoScroll: true
						,url: pre_url + '/info_pis_insig/create'
						,frame: true
						,monitorValid: true
						,bodyStyle: "padding:10px"
						,items:[
							{
								xtype: "hidden"
								,id: "pisinsig[id]"
								,value: data_personel_id
							}
							,{//ปีที่ขอรับ
								xtype: "numberfield"
								,id: "pisinsig[dcyear]"
								,fieldLabel: "ปีที่ขอรับ"
								,maxLength: 4
								,minLength: 4
							}
							,new Ext.ux.form.PisComboBox({//ชั้นเครื่องราชย์
								fieldLabel: 'ชั้นเครื่องราชย์'
								,hiddenName: 'pisinsig[dccode]'
								,id: 'pisinsig[dccode]'
								,valueField: 'dccode'
								,displayField: 'dcname'
								,urlStore: pre_url + '/code/cdecoratype'
                                                                ,fieldStore: ['dccode', 'dcname']
								,anchor: "90%"
								 
							})
							,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
								 fieldLabel: "ตำแหน่งสายงาน"
								 ,hiddenName: 'pisinsig[poscode]'
								 ,id: 'pisinsig[poscode]'
								 ,valueField: 'poscode'
								 ,displayField: 'posname'
								 ,urlStore: pre_url + '/code/cposition'
								 ,fieldStore: ['poscode', 'posname']
								 ,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ระดับ
								 fieldLabel: "ระดับ"
								 ,hiddenName: 'pisinsig[c]'
								 ,id: 'pisinsig[c]'
								 ,valueField: 'ccode'
								 ,displayField: 'cname'
								 ,urlStore: pre_url + '/code/cgrouplevel'
								 ,fieldStore: ['ccode', 'cname']
								 ,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
								fieldLabel: "ตำแหน่งบริหาร"
								,hiddenName: 'pisinsig[excode]'
								,id: 'pisinsig[excode]'
								,valueField: 'excode'
								,displayField: 'exname'
								,urlStore: pre_url + '/code/cexecutive'
								,fieldStore: ['excode', 'exname']
								,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
								fieldLabel: "ว./ว.ช/ชช."
								,hiddenName: 'pisinsig[ptcode]'
								,id: 'pisinsig[ptcode]'
								,valueField: 'ptcode'
								,displayField: 'ptname'
								,urlStore: pre_url + '/code/cpostype'
								,fieldStore: ['ptcode', 'ptname']
								,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
								fieldLabel: "ความเชี่ยวชาญ"
								,hiddenName: 'pisinsig[epcode]'
								,id: 'pisinsig[epcode]'
								,valueField: 'epcode'
								,displayField: 'expert'
								,urlStore: pre_url + '/code/cexpert'
								,fieldStore: ['epcode', 'expert']
								,anchor: "90%"
							})
							,{
								xtype: "fieldset"
								,layout: "form"
								,labelWidth: 180
								,anchor: "90%"
								,items: [
									{
										xtype: "datefield"
										,id: "pisinsig[kitjadate]"
										,fieldLabel: "ประกาศในราชกิจจานุเบกษาวันที่"
										,format: "d/m/Y"
									}
									,{
										layout: "column"
										,items: [
											{
												columnWidth: .5
												,layout: "form"
												,labelWidth: 100
												,items: [
													{
														xtype: "textfield"
														,id: "pisinsig[book]"
														,fieldLabel: "เล่มที่"
													}
													,{
														xtype: "textfield"
														,id: "pisinsig[pageno]"
														,fieldLabel: "หน้าที่"
													}
												]
											},{
												columnWidth: .5
												,layout: "form"
												,labelWidth: 100
												,items: [
													{
														xtype: "textfield"
														,id: "pisinsig[section]"
														,fieldLabel: "ตอนที่"
													}
													,{
														xtype: "textfield"
														,id: "pisinsig[seq]"
														,fieldLabel: "ลำดับที่"
													}	
												]
											}
										]
									}
								]
							},{
								layout: "column"
								,items: [
									{
										columnWidth: .5
										,layout: "form"
										,items: [
											{
												xtype: "datefield"
												,id: "pisinsig[recdate]"
												,fieldLabel: "วันที่รับเหรียญ"
												,format: "d/m/Y"
											}	
										]
									},{
										columnWidth: .5
										,layout: "form"
										,items: [
											{
												xtype: "datefield"
												,id: "pisinsig[retdate]"
												,fieldLabel: "วันที่คืนเหรียญ"
												,format: "d/m/Y"
											}
										]
									}
								]
							}
							,{
								xtype: "textfield"
								,id: "pisinsig[note]"
								,fieldLabel: "หมายเหตุ"
								,anchor: "90%"
							}
							,{
								xtype: "fieldset"
								,title: "ชดใช้เงินแทนเครื่องราชย์"
								,layout: "column"
								,anchor: "90%"
								,items: [
									{
										columnWidth: .5
										,layout: "form"
										,items: [
											{
												xtype: "textfield"
												,id: "pisinsig[bookno]"
												,fieldLabel: "ใบเสร็จเล่มที่"
											}
											,{
												xtype: "datefield"
												,id: "pisinsig[billdate]"
												,fieldLabel: "ลงวันที่"
												,format: "d/m/Y"
											}
										]
									}
									,{
										columnWidth: .5
										,layout: "form"
										,items: [
											{	
												xtype: "textfield"
												,id: "pisinsig[billno]"
												,fieldLabel: "เลขที่"
											}
											,{
												xtype: "textfield"
												,id: "pisinsig[money]"
												,fieldLabel: "จำนวนเงิน"
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
									form.getForm().submit(
									{ 
										method:'POST'
										,waitTitle:'Saving Data'
										,waitMsg:'Sending data...'
										,success:function(){		
											Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
													if (btn == 'ok')
													{
														data_insig_detailGridStore.reload();
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
						title: 'เพิ่ม/แก้ไข ประวัติเครื่องราชย์'
						,width: 800
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
							url: pre_url + '/info_pis_insig/delete' , 
							params: { 
								id: data_insig_detailGrid.getSelectionModel().getSelections()[0].data.id
								,dccode: data_insig_detailGrid.getSelectionModel().getSelections()[0].data.dccode
								,dcyear: data_insig_detailGrid.getSelectionModel().getSelections()[0].data.dcyear
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
												data_insig_detailGridStore.reload();
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
		}
		,"-",{
			text: "ปิด"
			,iconCls: "delete"
			,handler: function	(){                 
				tab_personel.getActiveTab().setTitle("ประวัติเครื่องราชย์");
				data_personel_id = "";
				tab_personel.getActiveTab().getLayout().setActiveItem(data_pis_insigGrid);
				data_pis_insigGridStore.load.reload();
			}
		}
	]
});

data_insig_detailGrid.getSelectionModel().on('selectionchange', function(sm){
     data_insig_detailGrid.removeBtn.setDisabled(sm.getCount() < 1);       
});
data_insig_detailGrid.on('rowdblclick', function(grid, rowIndex, e ) {
     record = grid.getSelectionModel().getSelected();
     loadMask.show();
     Ext.Ajax.request({
	     url: pre_url + '/info_pis_insig/search_edit'
	     ,params: {
		     id: record.data.id
		     ,dccode: record.data.dccode
		     ,dcyear: record.data.dcyear
	     }
	     ,success: function(response, opts) {
		     var obj = Ext.decode(response.responseText);
		     if (obj.success){
				data = obj.data.pisinsig;
				if(!form){
					var form = new Ext.FormPanel({ 
						labelWidth: 100
						,autoScroll: true
						,url: pre_url + '/info_pis_insig/edit'
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
								,id: "dccode"
								,value: data.dccode
							}
							,{
								xtype: "hidden"
								,id: "dcyear"
								,value: data.dcyear
							}
							,{//ปีที่ขอรับ
								xtype: "numberfield"
								,id: "pisinsig[dcyear]"
								,fieldLabel: "ปีที่ขอรับ"
								,maxLength: 4
								,minLength: 4
								,value: data.dcyear
							}
							,new Ext.ux.form.PisComboBox({//ชั้นเครื่องราชย์
								fieldLabel: 'ชั้นเครื่องราชย์'
								,hiddenName: 'pisinsig[dccode]'
								,id: 'pisinsig[dccode]'
								,valueField: 'dccode'
								,displayField: 'dcname'
								,urlStore: pre_url + '/code/cdecoratype'
                                                                ,fieldStore: ['dccode', 'dcname']
								,anchor: "90%"
								 
							})
							,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
								 fieldLabel: "ตำแหน่งสายงาน"
								 ,hiddenName: 'pisinsig[poscode]'
								 ,id: 'pisinsig[poscode]'
								 ,valueField: 'poscode'
								 ,displayField: 'posname'
								 ,urlStore: pre_url + '/code/cposition'
								 ,fieldStore: ['poscode', 'posname']
								 ,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ระดับ
								 fieldLabel: "ระดับ"
								 ,hiddenName: 'pisinsig[c]'
								 ,id: 'pisinsig[c]'
								 ,valueField: 'ccode'
								 ,displayField: 'cname'
								 ,urlStore: pre_url + '/code/cgrouplevel'
								 ,fieldStore: ['ccode', 'cname']
								 ,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
								fieldLabel: "ตำแหน่งบริหาร"
								,hiddenName: 'pisinsig[excode]'
								,id: 'pisinsig[excode]'
								,valueField: 'excode'
								,displayField: 'exname'
								,urlStore: pre_url + '/code/cexecutive'
								,fieldStore: ['excode', 'exname']
								,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
								fieldLabel: "ว./ว.ช/ชช."
								,hiddenName: 'pisinsig[ptcode]'
								,id: 'pisinsig[ptcode]'
								,valueField: 'ptcode'
								,displayField: 'ptname'
								,urlStore: pre_url + '/code/cpostype'
								,fieldStore: ['ptcode', 'ptname']
								,anchor: "90%"
							})
							,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
								fieldLabel: "ความเชี่ยวชาญ"
								,hiddenName: 'pisinsig[epcode]'
								,id: 'pisinsig[epcode]'
								,valueField: 'epcode'
								,displayField: 'expert'
								,urlStore: pre_url + '/code/cexpert'
								,fieldStore: ['epcode', 'expert']
								,anchor: "90%"
							})
							,{
								xtype: "fieldset"
								,layout: "form"
								,labelWidth: 180
								,anchor: "90%"
								,items: [
									{
										xtype: "datefield"
										,id: "pisinsig[kitjadate]"
										,fieldLabel: "ประกาศในราชกิจจานุเบกษาวันที่"
										,format: "d/m/Y"
										,value: to_date_app(data.kitjadate)
									}
									,{
										layout: "column"
										,items: [
											{
												columnWidth: .5
												,layout: "form"
												,labelWidth: 100
												,items: [
													{
														xtype: "textfield"
														,id: "pisinsig[book]"
														,fieldLabel: "เล่มที่"
														,value: data.book
													}
													,{
														xtype: "textfield"
														,id: "pisinsig[pageno]"
														,fieldLabel: "หน้าที่"
														,value: data.pageno
													}
												]
											},{
												columnWidth: .5
												,layout: "form"
												,labelWidth: 100
												,items: [
													{
														xtype: "textfield"
														,id: "pisinsig[section]"
														,fieldLabel: "ตอนที่"
														,value: data.section
													}
													,{
														xtype: "textfield"
														,id: "pisinsig[seq]"
														,fieldLabel: "ลำดับที่"
														,value: data.seq
													}	
												]
											}
										]
									}
								]
							},{
								layout: "column"
								,items: [
									{
										columnWidth: .5
										,layout: "form"
										,items: [
											{
												xtype: "datefield"
												,id: "pisinsig[recdate]"
												,fieldLabel: "วันที่รับเหรียญ"
												,format: "d/m/Y"
												,value: to_date_app(data.recdate)
											}	
										]
									},{
										columnWidth: .5
										,layout: "form"
										,items: [
											{
												xtype: "datefield"
												,id: "pisinsig[retdate]"
												,fieldLabel: "วันที่คืนเหรียญ"
												,format: "d/m/Y"
												,value: to_date_app(data.retdate)
											}
										]
									}
								]
							}
							,{
								xtype: "textfield"
								,id: "pisinsig[note]"
								,fieldLabel: "หมายเหตุ"
								,anchor: "90%"
								,value: data.note
							}
							,{
								xtype: "fieldset"
								,title: "ชดใช้เงินแทนเครื่องราชย์"
								,layout: "column"
								,anchor: "90%"
								,items: [
									{
										columnWidth: .5
										,layout: "form"
										,items: [
											{
												xtype: "textfield"
												,id: "pisinsig[bookno]"
												,fieldLabel: "ใบเสร็จเล่มที่"
												,value: data.bookno
											}
											,{
												xtype: "datefield"
												,id: "pisinsig[billdate]"
												,fieldLabel: "ลงวันที่"
												,format: "d/m/Y"
												,value: to_date_app(data.billdate)
											}
										]
									}
									,{
										columnWidth: .5
										,layout: "form"
										,items: [
											{	
												xtype: "textfield"
												,id: "pisinsig[billno]"
												,fieldLabel: "เลขที่"
												,value: data.billno
											}
											,{
												xtype: "textfield"
												,id: "pisinsig[money]"
												,fieldLabel: "จำนวนเงิน"
												,value: data.money
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
									form.getForm().submit(
									{ 
										method:'POST'
										,waitTitle:'Saving Data'
										,waitMsg:'Sending data...'
										,success:function(){		
											Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
													if (btn == 'ok')
													{
														data_insig_detailGridStore.reload();
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
						title: 'เพิ่ม/แก้ไข ประวัติเครื่องราชย์'
						,width: 800
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
				Ext.getCmp("pisinsig[poscode]").getStore().load({
					params: {
						 poscode: obj.data.pisinsig.poscode
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						 Ext.getCmp("pisinsig[poscode]").setValue(obj.data.pisinsig.poscode);
					}
                                });
				Ext.getCmp("pisinsig[dccode]").getStore().load({
					params: {
						 dccode: obj.data.pisinsig.dccode
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						 Ext.getCmp("pisinsig[dccode]").setValue(obj.data.pisinsig.dccode);
					}
                                });				
				Ext.getCmp("pisinsig[c]").getStore().load({
					params: {
						 ccode: obj.data.pisinsig.c
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						 Ext.getCmp("pisinsig[c]").setValue(obj.data.pisinsig.c);
					}
                                });				
				Ext.getCmp("pisinsig[excode]").getStore().load({
					params: {
						 excode: obj.data.pisinsig.excode
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						 Ext.getCmp("pisinsig[excode]").setValue(obj.data.pisinsig.excode);
					}
                                });				
				Ext.getCmp("pisinsig[ptcode]").getStore().load({
					params: {
						 ptcode: obj.data.pisinsig.ptcode
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						 Ext.getCmp("pisinsig[ptcode]").setValue(obj.data.pisinsig.ptcode);
					}
                                });				
				Ext.getCmp("pisinsig[epcode]").getStore().load({
					params: {
						 epcode: obj.data.pisinsig.epcode
						 ,start: 0
						 ,limit: 10
					}
					,callback :function(){
						 Ext.getCmp("pisinsig[epcode]").setValue(obj.data.pisinsig.epcode);
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