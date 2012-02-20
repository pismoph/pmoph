var code_deptRowEditor_number = 0;

var code_deptFields = [
	{name: "deptcode_tmp", type: "int"}
        ,{name: "deptcode", type: "int"}
	,{name: "deptname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_deptNewRecord = Ext.data.Record.create(code_deptFields);

var code_deptWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 deptcode_tmp: rec.data.deptcode_tmp
         ,deptcode: rec.data.deptcode
	 ,deptname: rec.data.deptname
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 deptcode_tmp: rec.data.deptcode_tmp
         ,deptcode: rec.data.deptcode
	 ,deptname: rec.data.deptname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_deptRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_deptRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_deptRowEditor_number = rowIndex;
		}
	}
});

var code_deptcheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_deptCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสกรม", width: 100, sortable: false, dataIndex: "deptcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
	 ,{header: "ชื่อกรม", width: 250, sortable: false, dataIndex: "deptname", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_deptcheckColumn
	 ,{header: "รหัสตำแหน่ง", width: 100, sortable: false, dataIndex: "deptcode",hidden: true}
];	

var code_deptSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_deptProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/cdept/read'
	   ,create: pre_url + '/cdept/create'
	   ,update: pre_url + '/cdept/update'
	   ,destroy: pre_url + '/cdept/delete'
   }
});	

var code_deptGridStore = new Ext.data.JsonStore({
	proxy: code_deptProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_deptFields
	,idProperty: 'deptcode'
	,successProperty: 'success'
	,writer: code_deptWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_deptGridStore.load({ params: { start: 0, limit: 20} });
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
									code_deptGridStore.removeAt(code_deptRowEditor_number);
									code_deptGrid.getView().refresh();
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
									code_deptGridStore.reload();
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

var code_deptGrid = new Ext.grid.GridPanel({
	title: "กรม"
	,region: 'center'
	,split: true
	,store: code_deptGridStore
	,columns: code_deptCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_deptRowEditor,code_deptSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_deptNewRecord({
                                    deptcode_tmp: ''
                                    ,deptcode: ''
                                    ,deptname: ''
                                    ,use_status: ''
				});
				code_deptRowEditor.stopEditing();
				code_deptGridStore.insert(0, e);
				code_deptGrid.getView().refresh();
				code_deptGrid.getSelectionModel().selectRow(0);
				code_deptRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_deptRowEditor.stopEditing();
				var s = code_deptGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_deptGridStore.remove(r);
					code_deptGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_deptGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cdept/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_deptGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cdept/report?format=pdf");
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
		,store: code_deptGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_deptRowEditor.stopEditing();
		}
	}
});

code_deptGrid.getSelectionModel().on('selectionchange', function(sm){
	code_deptGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
