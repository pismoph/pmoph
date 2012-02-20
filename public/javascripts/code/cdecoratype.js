var code_decoratypeRowEditor_number = 0;

var code_decoratypeFields = [
        {name: "dccode_tmp", type: "int"}
        ,{name: "dccode", type: "int"}
        ,{name: "shortname", type: "string"}
        ,{name: "dcname", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_decoratypeNewRecord = Ext.data.Record.create(code_decoratypeFields);

var code_decoratypeWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         dccode_tmp: rec.data.dccode_tmp
         ,dccode: rec.data.dccode
         ,shortname: rec.data.shortname
         ,dcname: rec.data.dcname
         ,use_status: rec.data.use_status
      };
      return data;   
   }
   ,updateRecord : function(rec) {
      data = {
         dccode_tmp: rec.data.dccode_tmp
         ,dccode: rec.data.dccode
         ,shortname: rec.data.shortname
         ,dcname: rec.data.dcname
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_decoratypeRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_decoratypeRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_decoratypeRowEditor_number = rowIndex;
                }
        }
});

var code_decoratypecheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_decoratypeCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "dccode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
        ,{header: "คำย่อ", width: 100, sortable: false, dataIndex: "shortname", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "เครื่องราชอิสริยาภรณ์", width: 250, sortable: false, dataIndex: "dcname", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_decoratypecheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "dccode",hidden: true}
];

var code_decoratypeSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_decoratypeProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cdecoratype/read'
           ,create: pre_url + '/cdecoratype/create'
           ,update: pre_url + '/cdecoratype/update'
           ,destroy: pre_url + '/cdecoratype/delete'
   }
});

var code_decoratypeGridStore = new Ext.data.JsonStore({
        proxy: code_decoratypeProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_decoratypeFields
        ,idProperty: 'dccode'
        ,successProperty: 'success'
        ,writer: code_decoratypeWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_decoratypeGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_decoratypeGridStore.removeAt(code_decoratypeRowEditor_number);
                                                                        code_decoratypeGrid.getView().refresh();
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
                                                                        code_decoratypeGridStore.reload();
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

var code_decoratypeGrid = new Ext.grid.GridPanel({
	title: "เครื่องราชอิสริยาภรณ์"
	,region: 'center'
	,split: true
	,store: code_decoratypeGridStore
	,columns: code_decoratypeCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_decoratypeRowEditor,code_decoratypeSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_decoratypeNewRecord({
									dccode_tmp: ""
									,dccode: ""
									,shortname: ""
									,dcname: ""
									,use_status: ""
							});
							code_decoratypeRowEditor.stopEditing();
							code_decoratypeGridStore.insert(0, e);
							code_decoratypeGrid.getView().refresh();
							code_decoratypeGrid.getSelectionModel().selectRow(0);
							code_decoratypeRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_decoratypeRowEditor.stopEditing();
							var s = code_decoratypeGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_decoratypeGridStore.remove(r);
									code_decoratypeGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_decoratypeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cdecoratype/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_decoratypeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cdecoratype/report?format=pdf");
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
			,store: code_decoratypeGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_decoratypeRowEditor.stopEditing();
		}
	}		
});

code_decoratypeGrid.getSelectionModel().on('selectionchange', function(sm){
        code_decoratypeGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
