var code_countryRowEditor_number = 0;

var code_countryFields = [
	{name: "cocode_tmp", type: "int"}
        ,{name: "cocode", type: "int"}
	,{name: "coname", type: "string"}
	,{name: "use_status", type: "bool"}
];	

var code_countryNewRecord = Ext.data.Record.create(code_countryFields);

var code_countryWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 cocode_tmp: rec.data.cocode_tmp
         ,cocode: rec.data.cocode
	 ,coname: rec.data.coname
	 ,use_status: rec.data.use_status
      };
      return data;
   
   }
   ,updateRecord : function(rec) {
      data = {
	 cocode_tmp: rec.data.cocode_tmp
         ,cocode: rec.data.cocode
	 ,coname: rec.data.coname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_countryRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj, data, rowIndex ) {	
			loadMask.show();
			code_countryRowEditor_number = rowIndex;
		}
		,canceledit: function(rowEditor, obj, data, rowIndex ) {	
			code_countryRowEditor_number = rowIndex;
		}
	}
});

var code_countrycheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_countryCols = [
	 {
	     header: "#"
	     ,width: 50
	     ,renderer: rowNumberer.createDelegate(this)
	     ,sortable: false
	 }
	 ,{header: "รหัสประเทศ", width: 100, sortable: false, dataIndex: "cocode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
	 ,{header: "ชื่อประเทศ", width: 250, sortable: false, dataIndex: "coname", editor: new Ext.form.TextField({allowBlank: false})}
	 ,code_countrycheckColumn
	 ,{header: "รหัสประเทศ", width: 100, sortable: false, dataIndex: "cocode",hidden: true}
];	

var code_countrySearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_countryProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url+'/ccountry/read'
	   ,create: pre_url + '/ccountry/create'
	   ,update: pre_url + '/ccountry/update'
	   ,destroy: pre_url + '/ccountry/delete'
   }
});	

var code_countryGridStore = new Ext.data.JsonStore({
	proxy: code_countryProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_countryFields
	,idProperty: 'cocode'
	,successProperty: 'success'
	,writer: code_countryWriter
	,autoSave: true
	,listeners: {
		write: function (store, action, result, res, rs){
			if (res.success == true)
			{
				code_countryGridStore.load({ params: { start: 0, limit: 20} });
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
									code_countryGridStore.removeAt(code_countryRowEditor_number);
									code_countryGrid.getView().refresh();
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
									code_countryGridStore.reload();
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

var code_countryGrid = new Ext.grid.GridPanel({
	title: "ประเทศ"
	,region: 'center'
	,split: true
	,store: code_countryGridStore
	,columns: code_countryCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_countryRowEditor,code_countrySearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_countryNewRecord({
                                    cocode_tmp: ''
                                    ,cocode: ''
                                    ,coname: ''
                                    ,use_status: ''
				});
				code_countryRowEditor.stopEditing();
				code_countryGridStore.insert(0, e);
				code_countryGrid.getView().refresh();
				code_countryGrid.getSelectionModel().selectRow(0);
				code_countryRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_countryRowEditor.stopEditing();
				var s = code_countryGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_countryGridStore.remove(r);
					code_countryGrid.getView().refresh();
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
							var data = Ext.util.JSON.encode(code_countryGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/ccountry/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_countryGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/ccountry/report?format=pdf");
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
		,store: code_countryGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_countryRowEditor.stopEditing();
		}
	}
});

code_countryGrid.getSelectionModel().on('selectionchange', function(sm){
	code_countryGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
