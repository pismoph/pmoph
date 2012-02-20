var code_executiveRowEditor_number = 0;

var code_executiveFields = [
	{name: "excode_tmp", type: "int"}
	,{name: "excode", type: "int"}
	,{name: "shortpre", type: "string"}
	,{name: "longpre", type: "string"}
	,{name: "exname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_executiveNewRecord = Ext.data.Record.create(code_executiveFields);

var code_executiveWriter = new Ext.data.JsonWriter({
   writeAllFields : true
   ,createRecord : function(rec) {
      data = {
	 excode_tmp: rec.data.excode_tmp
	 ,excode: rec.data.excode
	 ,shortpre: rec.data.shortpre
	 ,longpre: rec.data.longpre
	 ,exname: rec.data.exname
	 ,use_status: rec.data.use_status
      };
      return data;   
   }
   ,updateRecord : function(rec) {
      data = {
	 excode_tmp: rec.data.excode_tmp
	 ,excode: rec.data.excode
	 ,shortpre: rec.data.shortpre
	 ,longpre: rec.data.longpre
	 ,exname: rec.data.exname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_executiveRowEditor = new Ext.ux.grid.RowEditor({
	saveText		: 'บันทึก'
	,cancelText		: 'ยกเลิก'
	,listeners		: {
		validateedit	: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_executiveRowEditor_number = rowIndex;
		}
		,canceledit : function(rowEditor, obj, data, rowIndex ) {	
			code_executiveRowEditor_number = rowIndex;
		}
	}
});

var code_executivecheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_executiveCols = [
	{
		header: "#"
		,width: 50
		,renderer: rowNumberer.createDelegate(this)
		,sortable: false
	}
	,{header: "รหัสตำแหน่ง", width: 100, sortable: false, dataIndex: "excode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
	,{header: "ชื่อย่อคำนำหน้า", width: 100, sortable: false, dataIndex: "shortpre", editor: new Ext.form.TextField({allowBlank: false})}
	,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "longpre", editor: new Ext.form.TextField({allowBlank: false})}
	,{header: "ตำแหน่ง", width: 250, sortable: false, dataIndex: "exname", editor: new Ext.form.TextField({allowBlank: false})}
	,code_executivecheckColumn
	,{header: "รหัสตำแหน่ง", width: 100, sortable: false, dataIndex: "excode",hidden:true}
];	

var code_executiveSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_executiveProxy = new Ext.data.HttpProxy({
   api : {
	   read: pre_url + '/cexecutive/read'
	   ,create: pre_url + '/cexecutive/create'
	   ,update: pre_url + '/cexecutive/update'
	   ,destroy: pre_url + '/cexecutive/delete'
   }
});	

var code_executiveGridStore = new Ext.data.JsonStore({
	proxy: code_executiveProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_executiveFields
	,idProperty: 'excode'
	,successProperty: 'success'
	,writer: code_executiveWriter
	,autoSave: true
	,listeners			: {
		write : function (store, action, result, res, rs){
			if (res.success == true)			{
				code_executiveGridStore.load({ params: { start: 0, limit: 20} });
			} 
			loadMask.hide();		
		}
		,exception : function(proxy, type, action, option, res, arg) {
			if (action == "create"){
				var obj = Ext.util.JSON.decode(res.responseText);
				if (obj.success == false){
					if (obj.msg){					
						Ext.Msg.alert("สถานะ", obj.msg, 
							function(btn, text){										
								if (btn == 'ok'){
									code_executiveGridStore.removeAt(code_executiveRowEditor_number);
									code_executiveGrid.getView().refresh();
								}
							}
						);
					}
				}
			}
			if (action == "update"){
				if (res.success == false)
				{
					if (res.raw.msg)
					{					
						Ext.Msg.alert("สถานะ", res.raw.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_executiveGridStore.reload();
								}
							}
						);
					}
				}
			}
			loadMask.hide();
		}
	}	
});	

var code_executiveGrid = new Ext.grid.GridPanel({
	title: 'ตำแหน่งบริหาร'
	,region: 'center'
	,split: true
	,store: code_executiveGridStore
	,columns: code_executiveCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_executiveRowEditor, code_executiveSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_executiveNewRecord({
					excode_tmp: ""
					,excode: ""
					,shortpre: ""
					,longpre: ""
					,exname: ""
					,use_status: ""
				});
				code_executiveRowEditor.stopEditing();
				code_executiveGridStore.insert(0, e);
				code_executiveGrid.getView().refresh();
				code_executiveGrid.getSelectionModel().selectRow(0);
				code_executiveRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_executiveRowEditor.stopEditing();
				var s = code_executiveGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_executiveGridStore.remove(r);
					code_executiveGrid.getView().refresh();
				}
				loadMask.hide();
			}
		},"-",{
			text: "Export"
			,iconCls: "table-go"
			,menu: {
				items: [
					{
						text: "Excel"
						,iconCls: "excel"
						,handler: function() {
							var data = Ext.util.JSON.encode(code_executiveGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cexecutive/report?format=xls");
							form.setAttribute("target", "_blank");
							var hiddenField = document.createElement("input");              
							hiddenField.setAttribute("name", "data");
							hiddenField.setAttribute("value", data);
							form.appendChild(hiddenField);									
							document.body.appendChild(form);
							form.submit();
							document.body.removeChild(form);
						}
					},{
						text	: "PDF"
						,iconCls	: "pdf"
						,handler : function() {
							var data = Ext.util.JSON.encode(code_executiveGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cexecutive/report?format=pdf");
							form.setAttribute("target", "_blank");
							var hiddenField = document.createElement("input");              
							hiddenField.setAttribute("name", "data");
							hiddenField.setAttribute("value", data);
							form.appendChild(hiddenField);									
							document.body.appendChild(form);
							form.submit();
							document.body.removeChild(form);
						}
					}	
				]
			}
		}
	]
	,bbar: new Ext.PagingToolbar({
		pageSize: 20
		,autoWidth: true
		,store: code_executiveGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_executiveRowEditor.stopEditing();
		}
	}
});

code_executiveGrid.getSelectionModel().on('selectionchange', function(sm){
	code_executiveGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
