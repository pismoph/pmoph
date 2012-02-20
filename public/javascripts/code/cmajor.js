var code_majorRowEditor_number = 0;

var code_majorFields = [
        {name: "macode_tmp", type: "int"}
        ,{name: "macode", type: "string"}
        ,{name: "major", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_majorNewRecord = Ext.data.Record.create(code_majorFields);

var code_majorWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         macode_tmp: rec.data.macode_tmp
         ,macode: rec.data.macode	
         ,major: rec.data.major
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         macode_tmp: rec.data.macode_tmp
         ,macode: rec.data.macode	
         ,major: rec.data.major
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_majorRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_majorRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_majorRowEditor_number = rowIndex;
                }
        }
});

var code_majorcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_majorCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "macode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "สาขาวิชาเอก", width: 250, sortable: false, dataIndex: "major", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_majorcheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "macode", hidden:true}
];

var code_majorSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_majorProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cmajor/read'
           ,create: pre_url + '/cmajor/create'
           ,update: pre_url + '/cmajor/update'
           ,destroy: pre_url + '/cmajor/delete'
   }
});

var code_majorGridStore = new Ext.data.JsonStore({
        proxy: code_majorProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_majorFields
        ,idProperty: 'macode'
        ,successProperty: 'success'
        ,writer: code_majorWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_majorGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_majorGridStore.removeAt(code_majorRowEditor_number);
                                                                        code_majorGrid.getView().refresh();
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
                                                                        code_majorGridStore.reload();
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

var code_majorGrid = new Ext.grid.GridPanel({
	title: "สาขาวิชาเอก"
	,region: 'center'
	,split: true
	,store: code_majorGridStore
	,columns: code_majorCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_majorRowEditor,code_majorSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_majorNewRecord({
									macode_tmp: ""
									,macode: ""	
                                                                        ,major: ""
									,use_status: ""
							});
							code_majorRowEditor.stopEditing();
							code_majorGridStore.insert(0, e);
							code_majorGrid.getView().refresh();
							code_majorGrid.getSelectionModel().selectRow(0);
							code_majorRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_majorRowEditor.stopEditing();
							var s = code_majorGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_majorGridStore.remove(r);
									code_majorGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_majorGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cmajor/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_majorGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cmajor/report?format=pdf");
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
			,store: code_majorGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_majorRowEditor.stopEditing();
		}
	}
});

code_majorGrid.getSelectionModel().on('selectionchange', function(sm){
        code_majorGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
