var code_divisionRowEditor_number = 0;

var code_divisionFields = [
	{name: "dcode_tmp", type: "int"}
        ,{name: "dcode", type: "int"}        
        ,{name: "prefix", type: "string"}
	,{name: "division", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_divisionNewRecord = Ext.data.Record.create(code_divisionFields);

var code_divisionWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 dcode_tmp: rec.data.dcode_tmp
         ,dcode: rec.data.dcode
         ,prefix: rec.data.prefix
	 ,division: rec.data.division
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 dcode_tmp: rec.data.dcode_tmp
         ,dcode: rec.data.dcode
         ,prefix: rec.data.prefix
	 ,division: rec.data.division
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_divisionRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_divisionRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_divisionRowEditor_number = rowIndex;
		}
	}
});

var code_divisioncheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_divisionCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสกอง", width: 100, sortable: false, dataIndex: "dcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
	 ,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "prefix", editor: new Ext.form.TextField({allowBlank: false})}
         ,{header: "ชื่อกอง", width: 250, sortable: false, dataIndex: "division", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_divisioncheckColumn
	 ,{header: "รหัสตำแหน่ง", width: 100, sortable: false, dataIndex: "dcode",hidden: true}
];	

var code_divisionSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_divisionProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/cdivision/read'
	   ,create: pre_url + '/cdivision/create'
	   ,update: pre_url + '/cdivision/update'
	   ,destroy: pre_url + '/cdivision/delete'
   }
});	

var code_divisionGridStore = new Ext.data.JsonStore({
	proxy: code_divisionProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_divisionFields
	,idProperty: 'dcode'
	,successProperty: 'success'
	,writer: code_divisionWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_divisionGridStore.load({ params: { start: 0, limit: 20} });
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
									code_divisionGridStore.removeAt(code_divisionRowEditor_number);
									code_divisionGrid.getView().refresh();
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
									code_divisionGridStore.reload();
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

var code_divisionGrid = new Ext.grid.GridPanel({
	title: "กอง"
	,region: 'center'
	,split: true
	,store: code_divisionGridStore
	,columns: code_divisionCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_divisionRowEditor,code_divisionSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_divisionNewRecord({
                                    dcode_tmp: ''
                                    ,dcode: ''
                                    ,prefix: ''
                                    ,division: ''
                                    ,use_status: ''
				});
				code_divisionRowEditor.stopEditing();
				code_divisionGridStore.insert(0, e);
				code_divisionGrid.getView().refresh();
				code_divisionGrid.getSelectionModel().selectRow(0);
				code_divisionRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_divisionRowEditor.stopEditing();
				var s = code_divisionGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_divisionGridStore.remove(r);
					code_divisionGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_divisionGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cdivision/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_divisionGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cdivision/report?format=pdf");
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
		,store: code_divisionGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_divisionRowEditor.stopEditing();
		}
	}
});

code_divisionGrid.getSelectionModel().on('selectionchange', function(sm){
	code_divisionGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
