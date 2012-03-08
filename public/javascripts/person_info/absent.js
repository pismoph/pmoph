/********************************************************************/
/*Grid*/
/******************************************************************/    
var data_pis_absentSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});
var data_pis_absentFields = [
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

var data_pis_absentCols = [
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

var data_pis_absentGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_personal/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_pis_absentFields
	,idProperty: 'id'
});

var data_pis_absentGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_pis_absentGridStore
	,columns: data_pis_absentCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [data_pis_absentSearch]
	,bbar: new Ext.PagingToolbar({
			pageSize: 20
			,autoWidth: true
			,store: data_pis_absentGridStore
			,displayInfo: true
			,displayMsg	: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,tbar: ["&nbsp;"]
});
data_pis_absentGrid.on('rowdblclick', function(grid, rowIndex, e ) {
	data_select = grid.getSelectionModel().getSelected().data;
	data_personel_id = data_select.id;
	searchEditAbsent(data_select);
});

function searchEditAbsent(data_select){
	tab_personel.getActiveTab().setTitle("การลา ( " +data_select.name+ " )");		
	//tab_personel.getActiveTab().getLayout().setActiveItem(data_absent_detailGrid);
	tab_personel.getActiveTab().getLayout().setActiveItem(panel_absent);
	data_absent_detailGridStore.removeAll();
	Ext.getCmp("idfiscal").clearValue();
	Ext.getCmp("idfiscal").getStore().baseParams = {
		id: data_personel_id
	};
	Ext.getCmp("idfiscal").getStore().load({
		callback :function(){
			dt = new Date();			
			Ext.getCmp("idfiscal").setValue(dt.getFullYear());
			data_absent_detailGridStore.baseParams = {
				id: data_personel_id
				,year: dt.getFullYear()
			}
			data_absent_detailGridStore.load({ params: { start: 0, limit: 20} });
			summary_absentGridStore.removeAll();
			summary_absentGridStore.baseParams = {
				id: data_personel_id
				,year: Ext.getCmp("idfiscal").getValue()
			}
			summary_absentGridStore.load();
		}
	});
}
function searchAbsentById(personel_id){
      loadMask.show();
      Ext.Ajax.request({
	       url: pre_url + "/info_personal/search_id"
	       ,params: {
			id: personel_id
	       }
	       ,success: function(response,opts){
			obj = Ext.util.JSON.decode(response.responseText);
			 searchEditAbsent(obj.data[0]);
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
var data_absent_detailFields = [
    {name: "id", type: "string"}
    ,{name: "idp", type: "int"}
    ,{name: "abcode", type: "string"}
    ,{name: "abtype", type: "string"}
    ,{name: "begindate", type: "string"}
    ,{name: "enddate", type: "string"}
    ,{name: "amount", type: "string"}
    ,{name: "flagcount", type: "string"}
];
    
var data_absent_detailCols = [
     {
	      header: "#"
	      ,width: 80
	      ,renderer: rowNumberer.createDelegate(this)
	      ,sortable: false
      }
     ,{header: "เริ่มลาวันที่",width: 150, sortable: false, dataIndex: 'begindate'}
     ,{header: "ถึงวันที่",width: 150, sortable: false, dataIndex: 'enddate'}
     ,{header: "ประเภทการลา",width: 150, sortable: false, dataIndex: 'abtype'}
     ,{header: "จำนวนวัน",width: 150,sortable: false,dataIndex: 'amount'}
     ,{header: "นับครั้ง/ไม่นับครั้ง",width: 150, sortable: false, dataIndex: 'flagcount'}
];

var data_absent_detailGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_pis_absent/read"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: data_absent_detailFields
	,idProperty: 'idp'
});

var data_absent_detailGrid = new Ext.grid.GridPanel({
	region: 'center'
	,split: true
	,store: data_absent_detailGridStore
	,columns: data_absent_detailCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,bbar: new Ext.PagingToolbar({
		pageSize: 20
		,autoWidth: true
		,store: data_absent_detailGridStore
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
							 ,url: pre_url + '/info_pis_absent/create'
							 ,frame: true
							 ,monitorValid: true
							 ,bodyStyle: "padding:10px"
							 ,items:[
								 {
									xtype: "hidden"
									,id: "pisabsent[id]"
									,value: data_personel_id
								 }
								 ,new Ext.ux.form.PisComboBox({//ประเภทการลา
									fieldLabel: 'ประเภทการลา'
									,hiddenName: 'pisabsent[abcode]'
									,id: 'pisabsent[abcode]'
									,valueField: 'abcode'
									,displayField: 'abtype'
									,anchor: '95%'
									,urlStore: pre_url + '/code/cabsenttype'
									,fieldStore: ['abcode', 'abtype']
								 })
								 ,{
									 xtype: "datefield"
									 ,id: "pisabsent[begindate]"
									 ,fieldLabel: "วันลาเริ่มต้น"
									 ,format: "d/m/Y"
									 ,anchor: '95%'
								 },{
									 xtype: "datefield"
									 ,id: "pisabsent[enddate]"
									 ,fieldLabel: "วันลาสิ้นสุด"
									 ,format: "d/m/Y"
									 ,anchor: '95%'
								 },{
									 xtype: "numberfield"
									 ,id: "pisabsent[amount]"
									 ,fieldLabel: "จำนวนวัน"
									 ,anchor: '95%'
								 },{
									 xtype: "xcheckbox"
									 ,id: "pisabsent[flagcount]"
									 ,boxLabel: "นับครั้ง/ไม่นับครั้ง"
									 ,hideLabel: true
									 ,anchor: '95%'
									 ,submitOffValue:'0'
									 ,submitOnValue:'1'
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
															 data_absent_detailGridStore.reload();
															 win.close();
															 summary_absentGridStore.removeAll();
															summary_absentGridStore.baseParams = {
																id: data_personel_id
																,year: Ext.getCmp("idfiscal").getValue()
															}
															summary_absentGridStore.load();
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
							 title: 'เพิ่ม/แก้ไข การลา'
							 ,width: 400
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
								    url: pre_url + '/info_pis_absent/delete' , 
								    params: { 
									    id: data_absent_detailGrid.getSelectionModel().getSelected().data.id
									    ,abcode: data_absent_detailGrid.getSelectionModel().getSelected().data.abcode
									    ,begindate: data_absent_detailGrid.getSelectionModel().getSelected().data.begindate
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
										    data_absent_detailGridStore.reload();
									    }
									    else if (obj.success == true){
										    Ext.MessageBox.alert('สถานะ', 'ลบเสร็จเรียบร้อย',function(btn, text){
												    if (btn == 'ok'){
													    data_absent_detailGridStore.reload();
													    summary_absentGridStore.removeAll();
													    	summary_absentGridStore.baseParams = {
															id: data_personel_id
															,year: Ext.getCmp("idfiscal").getValue()
														}
														summary_absentGridStore.load();
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
					    tab_personel.getActiveTab().setTitle("การลา");
					    data_personel_id = "";
					    tab_personel.getActiveTab().getLayout().setActiveItem(data_pis_absentGrid); 
					    data_pis_absentGridStore.reload();
				    }
			    },"->"
			    ,"ปีงบประมาณ:"
			    ,new Ext.ux.form.PisComboBox({
				    hiddenName: 'fiscal'
				    ,id: 'idfiscal'
				    ,valueField: 'year_en'
				    ,displayField: 'year_th'
				    ,urlStore: pre_url + '/info_pis_absent/genre_year_fiscal'
				    ,fieldStore: ['year_en', 'year_th']
				    ,listeners: {
					    select: function(combo,record,index ){
						    data_absent_detailGridStore.baseParams = {
							    id: data_personel_id
							    ,year:record.data.year_en
						    }
						    data_absent_detailGridStore.load({ params: { start: 0, limit: 20} });
					    }						
				    }
			    })
		    ]
});

data_absent_detailGrid.getSelectionModel().on('selectionchange', function(sm){
     data_absent_detailGrid.removeBtn.setDisabled(sm.getCount() < 1);       
});
data_absent_detailGrid.on('rowdblclick', function(grid, rowIndex, e ) {
     record = grid.getSelectionModel().getSelected();
     loadMask.show();
     Ext.Ajax.request({
	     url: pre_url + '/info_pis_absent/search_edit'
	     ,params: {
		     id: record.data.id
		     ,abcode: record.data.abcode
		     ,begindate: record.data.begindate
	     }
	     ,success: function(response, opts) {
		     var obj = Ext.decode(response.responseText);
		     if (obj.success){
				data = obj.data.pisabsent
				if(!form){
					var form = new Ext.FormPanel({ 
						labelWidth: 100
						,autoScroll: true
						,url: pre_url + '/info_pis_absent/edit'
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
							       ,id: "abcode"
							       ,value: data.abcode
							}
							,{
							       xtype: "hidden"
							       ,id: "begindate"
							       ,value: to_date_app(data.begindate)
							}
							,new Ext.ux.form.PisComboBox({//ประเภทการลา
							       fieldLabel: 'ประเภทการลา'
							       ,hiddenName: 'pisabsent[abcode]'
							       ,id: 'pisabsent[abcode]'
							       ,valueField: 'abcode'
							       ,displayField: 'abtype'
							       ,anchor: '95%'
							       ,urlStore: pre_url + '/code/cabsenttype'
							       ,fieldStore: ['abcode', 'abtype']
							})
							,{
								xtype: "datefield"
								,id: "pisabsent[begindate]"
								,fieldLabel: "วันลาเริ่มต้น"
								,format: "d/m/Y"
								,anchor: '95%'
								,value: to_date_app(data.begindate)
							}
							,{
								xtype: "datefield"
								,id: "pisabsent[enddate]"
								,fieldLabel: "วันลาสิ้นสุด"
								,format: "d/m/Y"
								,anchor: '95%'
								,value: to_date_app(data.enddate)
							}
							,{
								xtype: "numberfield"
								,id: "pisabsent[amount]"
								,fieldLabel: "จำนวนวัน"
								,anchor: '95%'
								,value: data.amount
							}
							,{
								xtype: "xcheckbox"
								,id: "pisabsent[flagcount]"
								,boxLabel: "นับครั้ง/ไม่นับครั้ง"
								,hideLabel: true
								,anchor: '95%'
								,submitOffValue:'0'
								,submitOnValue:'1'
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
														data_absent_detailGridStore.reload();
														win.close();
														summary_absentGridStore.removeAll();
														summary_absentGridStore.baseParams = {
															id: data_personel_id
															,year: Ext.getCmp("idfiscal").getValue()
														}
														summary_absentGridStore.load();
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
						title: 'เพิ่ม/แก้ไข การลา'
						,width: 400
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
				Ext.getCmp("pisabsent[flagcount]").setValue(data.flagcount);
				Ext.getCmp("pisabsent[abcode]").getStore().load({
					params: {
						abcode: data.abcode
						,start: 0
						,limit: 10
					}
					,callback :function(){
						Ext.getCmp("pisabsent[abcode]").setValue(data.abcode);
						win.show();
						win.center();
						loadMask.hide();
					}
				});	
		     }
		     else{
			loadMask.hide();
		     }
		     
	     }
	     ,failure: function(response, opts) {
		     Ext.Msg.alert("สถานะ", response.statusText);
		     loadMask.hide();
	     }
     });         
});

/********************************************************************/
/*Summary Absent*/
/******************************************************************/
var summary_absent_fields = [
    {name: "id", type: "string"}
    ,{name: "abtype", type: "string"}
    ,{name: "amount", type: "string"}
    ,{name: "flagcount", type: "string"}
];

var summary_absent_cols = [
     {header: "ประเภทการลา",width: 120, sortable: false, dataIndex: 'abtype'}
     ,{header: "จำนวนวัน",width: 80,sortable: false,dataIndex: 'amount'}
     ,{header: "จำนวนครั้ง",width: 80, sortable: false, dataIndex: 'flagcount'}
];

var summary_absentGridStore = new Ext.data.JsonStore({
	url: pre_url + "/info_pis_absent/summary"
	,root: "records"
	,autoLoad: false
	,totalProperty: 'totalCount'
	,fields: summary_absent_fields
	,idProperty: 'id'
});

var summary_absentGrid = new Ext.grid.GridPanel({
	region: 'south'
	,height: 300
	,store: summary_absentGridStore
	,columns: summary_absent_cols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
});

/********************************************************************/
/*Holiday*/
/******************************************************************/
form_absent = new Ext.FormPanel({
	region: "north"
	,title: "วันลาพักผ่อน ปีงบปัจจุบัน"
	,labelWidth: 170
	,height: 200
	,autoScroll: true
	,url: pre_url + '/info_pis_absent/create'
	,frame: true
	,monitorValid: true
	,bodyStyle: "padding:10px"
	,items:[
		{
			xtype: "compositefield"
			,fieldLabel: "ยอดยกมาจากปีงบประมาณที่แล้ว"
			,items: [
				{
					xtype: "numberfield"
					,id: "holiday[balance]"
					,width: 50
				}
				,{
					xtype: "displayfield"
					,style: "padding: 4px;text-align: right"
					,value: "วัน"
				}
			]
		}
		,{
			html: "<font style='font:12px tahoma,arial,helvetica,sans-serif;'>สะสมในปีงบประมาณนี้:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;วัน</font>"
		}
		,{
			xtype: "compositefield"
			,fieldLabel: "เมื่อ 1 ต.ค. ปีงบประมาณปัจจุบัน"
			,items: [
				{
					xtype: "numberfield"
					,id: "holiday[vac1oct]"
					,width: 50
				}				
				,{
					xtype: "displayfield"
					,style: "padding: 4px;text-align: right"
					,value: "วัน"
				}
			]
		}
		,{
			xtype: "compositefield"
			,fieldLabel: "วันลาพักผ่อนสะสม คงเหลือ"
			,items: [
				{
					xtype: "numberfield"
					,id: "holiday[totalabsent]"
					,width: 50
				}
				,{
					xtype: "displayfield"
					,style: "padding: 4px;text-align: right"
					,value: "วัน"
				}
			]
		}	
	]
	,buttons:[
		{ 
			text:'บันทึก'
			,formBind: true 
			,handler:function(){
				return 0;
				form.getForm().submit(
				{ 
					method:'POST'
					,waitTitle:'Saving Data'
					,waitMsg:'Sending data...'
					,success:function(){		
						Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
								if (btn == 'ok')
								{
									data_absent_detailGridStore.reload();
									win.close();
									summary_absentGridStore.removeAll();
								       summary_absentGridStore.baseParams = {
									       id: data_personel_id
									       ,year: Ext.getCmp("idfiscal").getValue()
								       }
								       summary_absentGridStore.load();
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
	] 
});




/********************************************************************/
/*Panel*/
/******************************************************************/

var panel_absent = new Ext.Panel({
	layout: "border"
	,items: [
		{
			layout: "border"
			,region: "east"
			,width: 300
			,items: [
				form_absent
				,{
					region: "center"
					,frame: true
				}
				,summary_absentGrid
			]
		}
		,data_absent_detailGrid
	]
	,listeners: {
		 afterrender: function(el){
			  el.doLayout();
		 }
	} 
});