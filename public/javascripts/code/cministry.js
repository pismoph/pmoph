var code_ministryRowEditor_number = 0;

var code_ministryFields = [
	{name: "mcode_tmp", type: "int"}
        ,{name: "mcode", type: "int"}
	,{name: "minname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_ministryNewRecord = Ext.data.Record.create(code_ministryFields);

var code_ministryWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 mcode_tmp: rec.data.mcode_tmp
         ,mcode: rec.data.mcode
	 ,minname: rec.data.minname
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 mcode_tmp: rec.data.mcode_tmp
         ,mcode: rec.data.mcode
	 ,minname: rec.data.minname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_ministryRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_ministryRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_ministryRowEditor_number = rowIndex;
		}
	}
});

var code_ministrycheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_ministryCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสกระทรวง", width: 100, sortable: false, dataIndex: "mcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
	 ,{header: "ชื่อกระทรวง", width: 250, sortable: false, dataIndex: "minname", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_ministrycheckColumn
	 ,{header: "รหัสตำแหน่ง", width: 100, sortable: false, dataIndex: "mcode",hidden: true}
];	

var code_ministrySearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_ministryProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/cministry/read'
	   ,create: pre_url + '/cministry/create'
	   ,update: pre_url + '/cministry/update'
	   ,destroy: pre_url + '/cministry/delete'
   }
});	

var code_ministryGridStore = new Ext.data.JsonStore({
	proxy: code_ministryProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_ministryFields
	,idProperty: 'mcode'
	,successProperty: 'success'
	,writer: code_ministryWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_ministryGridStore.load({ params: { start: 0, limit: 20} });
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
									code_ministryGridStore.removeAt(code_ministryRowEditor_number);
									code_ministryGrid.getView().refresh();
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
									code_ministryGridStore.reload();
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

var code_ministryGrid = new Ext.grid.GridPanel({
	title: "กระทรวง"
	,region: 'center'
	,split: true
	,store: code_ministryGridStore
	,columns: code_ministryCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_ministryRowEditor,code_ministrySearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_ministryNewRecord({
                                    mcode_tmp: ''
                                    ,mcode: ''
                                    ,minname: ''
                                    ,use_status: ''
				});
				code_ministryRowEditor.stopEditing();
				code_ministryGridStore.insert(0, e);
				code_ministryGrid.getView().refresh();
				code_ministryGrid.getSelectionModel().selectRow(0);
				code_ministryRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_ministryRowEditor.stopEditing();
				var s = code_ministryGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_ministryGridStore.remove(r);
					code_ministryGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_ministryGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cministry/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_ministryGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/cministry/report?format=pdf");
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
		,store: code_ministryGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_ministryRowEditor.stopEditing();
		}
	}
});

code_ministryGrid.getSelectionModel().on('selectionchange', function(sm){
	code_ministryGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
