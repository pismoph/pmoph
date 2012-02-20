var code_punishRowEditor_number = 0;

var code_punishFields = [
        {name: "pncode_tmp", type: "int"}
        ,{name: "pncode", type: "string"}
        ,{name: "pnname", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_punishNewRecord = Ext.data.Record.create(code_punishFields);

var code_punishWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         pncode_tmp: rec.data.pncode_tmp
         ,pncode: rec.data.pncode	
         ,pnname: rec.data.pnname
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         pncode_tmp: rec.data.pncode_tmp
         ,pncode: rec.data.pncode	
         ,pnname: rec.data.pnname
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_punishRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_punishRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_punishRowEditor_number = rowIndex;
                }
        }
});

var code_punishcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_punishCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "pncode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "การลงโทษทางวินัย", width: 250, sortable: false, dataIndex: "pnname", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_punishcheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "pncode", hidden:true}
];

var code_punishSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_punishProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cpunish/read'
           ,create: pre_url + '/cpunish/create'
           ,update: pre_url + '/cpunish/update'
           ,destroy: pre_url + '/cpunish/delete'
   }
});

var code_punishGridStore = new Ext.data.JsonStore({
        proxy: code_punishProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_punishFields
        ,idProperty: 'pncode'
        ,successProperty: 'success'
        ,writer: code_punishWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_punishGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_punishGridStore.removeAt(code_punishRowEditor_number);
                                                                        code_punishGrid.getView().refresh();
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
                                                                        code_punishGridStore.reload();
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

var code_punishGrid = new Ext.grid.GridPanel({
	title: "การลงโทษทางวินัย"
	,region: 'center'
	,split: true
	,store: code_punishGridStore
	,columns: code_punishCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_punishRowEditor,code_punishSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_punishNewRecord({
									pncode_tmp: ""
									,pncode: ""	
                                                                        ,pnname: ""
									,use_status: ""
							});
							code_punishRowEditor.stopEditing();
							code_punishGridStore.insert(0, e);
							code_punishGrid.getView().refresh();
							code_punishGrid.getSelectionModel().selectRow(0);
							code_punishRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_punishRowEditor.stopEditing();
							var s = code_punishGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_punishGridStore.remove(r);
									code_punishGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_punishGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cpunish/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_punishGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cpunish/report?format=pdf");
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
			,store: code_punishGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_punishRowEditor.stopEditing();
		}
	}
});

code_punishGrid.getSelectionModel().on('selectionchange', function(sm){
        code_punishGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
