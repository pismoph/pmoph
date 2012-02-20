var code_sectionRowEditor_number = 0;

var code_sectionFields = [
	{name: "seccode_tmp", type: "int"}
        ,{name: "seccode", type: "int"}        
        ,{name: "shortname", type: "string"}
	,{name: "secname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_sectionNewRecord = Ext.data.Record.create(code_sectionFields);

var code_sectionWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 seccode_tmp: rec.data.seccode_tmp
         ,seccode: rec.data.seccode
         ,shortname: rec.data.shortname
	 ,secname: rec.data.secname
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 seccode_tmp: rec.data.seccode_tmp
         ,seccode: rec.data.seccode
         ,shortname: rec.data.shortname
	 ,secname: rec.data.secname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_sectionRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_sectionRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_sectionRowEditor_number = rowIndex;
		}
	}
});

var code_sectioncheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_sectionCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสฝ่าย/กลุ่มงาน", width: 100, sortable: false, dataIndex: "seccode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
	 ,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "shortname", editor: new Ext.form.TextField({allowBlank: false})}
         ,{header: "ชื่อฝ่าย/กลุ่มงาน", width: 250, sortable: false, dataIndex: "secname", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_sectioncheckColumn
	 ,{header: "รหัสฝ่าย/กลุ่มงาน", width: 100, sortable: false, dataIndex: "seccode",hidden: true}
];	

var code_sectionSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_sectionProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/csection/read'
	   ,create: pre_url + '/csection/create'
	   ,update: pre_url + '/csection/update'
	   ,destroy: pre_url + '/csection/delete'
   }
});	

var code_sectionGridStore = new Ext.data.JsonStore({
	proxy: code_sectionProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_sectionFields
	,idProperty: 'seccode'
	,successProperty: 'success'
	,writer: code_sectionWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_sectionGridStore.load({ params: { start: 0, limit: 20} });
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
									code_sectionGridStore.removeAt(code_sectionRowEditor_number);
									code_sectionGrid.getView().refresh();
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
									code_sectionGridStore.reload();
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

var code_sectionGrid = new Ext.grid.GridPanel({
	title: "ฝ่าย/กลุ่มงาน"
	,region: 'center'
	,split: true
	,store: code_sectionGridStore
	,columns: code_sectionCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_sectionRowEditor,code_sectionSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_sectionNewRecord({
                                    seccode_tmp: ''
                                    ,seccode: ''
                                    ,shortname: ''
                                    ,secname: ''
                                    ,use_status: ''
				});
				code_sectionRowEditor.stopEditing();
				code_sectionGridStore.insert(0, e);
				code_sectionGrid.getView().refresh();
				code_sectionGrid.getSelectionModel().selectRow(0);
				code_sectionRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_sectionRowEditor.stopEditing();
				var s = code_sectionGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_sectionGridStore.remove(r);
					code_sectionGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_sectionGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/csection/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_sectionGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/csection/report?format=pdf");
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
		,store: code_sectionGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_sectionRowEditor.stopEditing();
		}
	}
});

code_sectionGrid.getSelectionModel().on('selectionchange', function(sm){
	code_sectionGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
