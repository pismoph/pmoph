var code_provinceRowEditor_number = 0;

var code_provinceFields = [
	{name: "provcode", type: "int"}
	,{name: "provcode_tmp", type: "int"}
	,{name: "shortpre", type: "string"}
	,{name: "longpre", type: "string"}
	,{name: "provname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_provinceNewRecord = Ext.data.Record.create(code_provinceFields);

var code_provinceWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 longpre: rec.data.longpre
	 ,provcode: rec.data.provcode
	 ,provcode_tmp: rec.data.provcode_tmp
	 ,provname: rec.data.provname
	 ,shortpre: rec.data.shortpre
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 longpre: rec.data.longpre
	 ,provcode: rec.data.provcode
	 ,provcode_tmp: rec.data.provcode_tmp
	 ,provname: rec.data.provname
	 ,shortpre: rec.data.shortpre
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_provinceRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_provinceRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_provinceRowEditor_number = rowIndex;
		}
	}
});

var code_provincecheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_provinceCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสจังหวัด", width: 100, sortable: false, dataIndex: "provcode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
	 ,{header: "ชื่อย่อคำนำหน้า", width: 100, sortable: false, dataIndex: "shortpre", editor: new Ext.form.TextField({allowBlank: false })}
	 ,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "longpre", editor: new Ext.form.TextField({allowBlank: false})}
	 ,{header: "จังหวัด", width: 250, sortable: false, dataIndex: "provname", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_provincecheckColumn
	 ,{header: "รหัสจังหวัด", width: 100, sortable: false, dataIndex: "provcode",hidden: true}
];	

var code_provinceSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_provinceProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/cprovince/read'
	   ,create: pre_url + '/cprovince/create'
	   ,update: pre_url + '/cprovince/update'
	   ,destroy: pre_url + '/cprovince/delete'
   }
});	

var code_provinceGridStore = new Ext.data.JsonStore({
	proxy: code_provinceProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_provinceFields
	,idProperty: 'provcode'
	,successProperty: 'success'
	,writer: code_provinceWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_provinceGridStore.load({ params: { start: 0, limit: 20} });
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
									code_provinceGridStore.removeAt(code_provinceRowEditor_number);
									code_provinceGrid.getView().refresh();
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
									code_provinceGridStore.reload();
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

var code_provinceGrid = new Ext.grid.GridPanel({
	title: "จังหวัด"
	,region: 'center'
	,split: true
	,store: code_provinceGridStore
	,columns: code_provinceCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_provinceRowEditor,code_provinceSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_provinceNewRecord({
					provcode_tmp: ""
					,provcode: ""
					,shortpre: ""
					,longpre: ""
					,provname: ""
					,use_status: ""
				});
				code_provinceRowEditor.stopEditing();
				code_provinceGridStore.insert(0, e);
				code_provinceGrid.getView().refresh();
				code_provinceGrid.getSelectionModel().selectRow(0);
				code_provinceRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_provinceRowEditor.stopEditing();
				var s = code_provinceGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_provinceGridStore.remove(r);
					code_provinceGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_provinceGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cprovince/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_provinceGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cprovince/report?format=pdf");
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
		,store: code_provinceGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_provinceRowEditor.stopEditing();
		}
	}
});

code_provinceGrid.getSelectionModel().on('selectionchange', function(sm){
	code_provinceGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
