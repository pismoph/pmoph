var code_jobRowEditor_number = 0;

var code_jobFields = [
	{name: "jobcode_tmp", type: "int"}
        ,{name: "jobcode", type: "int"}
	,{name: "jobname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_jobNewRecord = Ext.data.Record.create(code_jobFields);

var code_jobWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 jobcode_tmp: rec.data.jobcode_tmp
         ,jobcode: rec.data.jobcode
	 ,jobname: rec.data.jobname
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 jobcode_tmp: rec.data.jobcode_tmp
         ,jobcode: rec.data.jobcode
	 ,jobname: rec.data.jobname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_jobRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_jobRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_jobRowEditor_number = rowIndex;
		}
	}
});

var code_jobcheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_jobCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสงาน", width: 100, sortable: false, dataIndex: "jobcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
	 ,{header: "ชื่องาน", width: 250, sortable: false, dataIndex: "jobname", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_jobcheckColumn
	 ,{header: "รหัสงาน", width: 100, sortable: false, dataIndex: "jobcode",hidden: true}
];	

var code_jobSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_jobProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/cjob/read'
	   ,create: pre_url + '/cjob/create'
	   ,update: pre_url + '/cjob/update'
	   ,destroy: pre_url + '/cjob/delete'
   }
});	

var code_jobGridStore = new Ext.data.JsonStore({
	proxy: code_jobProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_jobFields
	,idProperty: 'jobcode'
	,successProperty: 'success'
	,writer: code_jobWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_jobGridStore.load({ params: { start: 0, limit: 20} });
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
									code_jobGridStore.removeAt(code_jobRowEditor_number);
									code_jobGrid.getView().refresh();
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
									code_jobGridStore.reload();
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

var code_jobGrid = new Ext.grid.GridPanel({
	title: "งาน"
	,region: 'center'
	,split: true
	,store: code_jobGridStore
	,columns: code_jobCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_jobRowEditor,code_jobSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_jobNewRecord({
                                    jobcode_tmp: ''
                                    ,jobcode: ''
                                    ,jobname: ''
                                    ,use_status: ''
				});
				code_jobRowEditor.stopEditing();
				code_jobGridStore.insert(0, e);
				code_jobGrid.getView().refresh();
				code_jobGrid.getSelectionModel().selectRow(0);
				code_jobRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_jobRowEditor.stopEditing();
				var s = code_jobGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_jobGridStore.remove(r);
					code_jobGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_jobGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cjob/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_jobGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cjob/report?format=pdf");
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
		,store: code_jobGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_jobRowEditor.stopEditing();
		}
	}
});

code_jobGrid.getSelectionModel().on('selectionchange', function(sm){
	code_jobGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
