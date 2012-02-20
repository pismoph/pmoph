var code_qualifyRowEditor_number = 0;

var code_qualifyFields = [
	{name: "qcode", type: "int"}
	,{name: "qcode_tmp", type: "int"}
	,{name: "shortpre", type: "string"}
	,{name: "longpre", type: "string"}
	,{name: "qualify", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_qualifyNewRecord = Ext.data.Record.create(code_qualifyFields);

var code_qualifyWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 longpre: rec.data.longpre
	 ,qcode: rec.data.qcode
	 ,qcode_tmp: rec.data.qcode_tmp
	 ,qualify: rec.data.qualify
	 ,shortpre: rec.data.shortpre
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 longpre: rec.data.longpre
	 ,qcode: rec.data.qcode
	 ,qcode_tmp: rec.data.qcode_tmp
	 ,qualify: rec.data.qualify
	 ,shortpre: rec.data.shortpre
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_qualifyRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_qualifyRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_qualifyRowEditor_number = rowIndex;
		}
	}
});

var code_qualifycheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_qualifyCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัส", width: 100, sortable: false, dataIndex: "qcode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
	 ,{header: "ชื่อย่อคำนำหน้า", width: 100, sortable: false, dataIndex: "shortpre", editor: new Ext.form.TextField({allowBlank: false })}
	 ,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "longpre", editor: new Ext.form.TextField({allowBlank: false})}
	 ,{header: "วุฒิการศึกษา", width: 250, sortable: false, dataIndex: "qualify", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_qualifycheckColumn
	 ,{header: "รหัส", width: 100, sortable: false, dataIndex: "qcode",hidden: true}
];	

var code_qualifySearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_qualifyProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/cqualify/read'
	   ,create: pre_url + '/cqualify/create'
	   ,update: pre_url + '/cqualify/update'
	   ,destroy: pre_url + '/cqualify/delete'
   }
});	

var code_qualifyGridStore = new Ext.data.JsonStore({
	proxy: code_qualifyProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_qualifyFields
	,idProperty: 'qcode'
	,successProperty: 'success'
	,writer: code_qualifyWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_qualifyGridStore.load({ params: { start: 0, limit: 20} });
			} 
			loadMask.hide();		
		}
		,exception: function(proxy, type, action, option, res, arg) {
			if (action == "create")
			{
				var obj = Ext.util.JSON.decode(res.responseText);
				if (obj.success == false)
				{
					if (obj.msg)
					{					
						Ext.Msg.alert("สถานะ", obj.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_qualifyGridStore.removeAt(code_qualifyRowEditor_number);
									code_qualifyGrid.getView().refresh();
								}
							}
						);
					}
				}
			}
			if (action == "update")
			{
				if (res.success == false)
				{
					if (res.raw.msg)
					{					
						Ext.Msg.alert("สถานะ", res.raw.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_qualifyGridStore.reload();
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

var code_qualifyGrid = new Ext.grid.GridPanel({
	title: "วุฒิการศึกษา"
	,region: 'center'
	,split: true
	,store: code_qualifyGridStore
	,columns: code_qualifyCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_qualifyRowEditor,code_qualifySearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_qualifyNewRecord({
					qcode_tmp: ""
					,qcode: ""
					,shortpre: ""
					,longpre: ""
					,qualify: ""
					,use_status: ""
				});
				code_qualifyRowEditor.stopEditing();
				code_qualifyGridStore.insert(0, e);
				code_qualifyGrid.getView().refresh();
				code_qualifyGrid.getSelectionModel().selectRow(0);
				code_qualifyRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_qualifyRowEditor.stopEditing();
				var s = code_qualifyGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_qualifyGridStore.remove(r);
					code_qualifyGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_qualifyGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cqualify/report?format=xls");
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
						text: "PDF"
						,iconCls: "pdf"
						,handler: function() {
							var data = Ext.util.JSON.encode(code_qualifyGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cqualify/report?format=pdf");
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
		,store: code_qualifyGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_qualifyRowEditor.stopEditing();
		}
	}
});

code_qualifyGrid.getSelectionModel().on('selectionchange', function(sm){
	code_qualifyGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
