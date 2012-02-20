var code_updateRowEditor_number = 0;

var code_updateFields = [
        {name: "updcode_tmp", type: "int"}
        ,{name: "updcode", type: "int"}
        ,{name: "updname", type: "string"}
        ,{name: "updsort", type: "int"}
        ,{name: "use_status", type: "bool"}
];

var code_updateNewRecord = Ext.data.Record.create(code_updateFields);

var code_updateWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         updcode_tmp: rec.data.updcode_tmp
         ,updcode: rec.data.updcode
         ,updname: rec.data.updname
         ,updsort: rec.data.updsort
         ,use_status: rec.data.use_status
      };
      return data;  
   }
   ,updateRecord : function(rec) {
      data = {
         updcode_tmp: rec.data.updcode_tmp
         ,updcode: rec.data.updcode
         ,updname: rec.data.updname
         ,updsort: rec.data.updsort
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_updateRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_updateRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_updateRowEditor_number = rowIndex;
                }
        }
});

var code_updatecheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_updateCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "updcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "การเคลื่อนไหว", width: 300, sortable: false, dataIndex: "updname", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "เรียงลำดับ", width: 100, sortable: false, dataIndex: "updsort", editor: new Ext.form.NumberField({allowBlank: false})}
        ,code_updatecheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "updcode", hidden:true}
];

var code_updateSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_updateProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cupdate/read'
           ,create: pre_url + '/cupdate/create'
           ,update: pre_url + '/cupdate/update'
           ,destroy: pre_url + '/cupdate/delete'
   }
});

var code_updateGridStore = new Ext.data.JsonStore({
        proxy: code_updateProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_updateFields
        ,idProperty: 'updcode'
        ,successProperty: 'success'
        ,writer: code_updateWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_updateGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_updateGridStore.removeAt(code_updateRowEditor_number);
                                                                        code_updateGrid.getView().refresh();
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
                                                                        code_updateGridStore.reload();
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

var code_updateGrid = new Ext.grid.GridPanel({
	title: "รหัสการเคลื่อนไหว"
	,region: 'center'
	,split: true
	,store: code_updateGridStore
	,columns: code_updateCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_updateRowEditor,code_updateSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_updateNewRecord({
									updcode_tmp: ""
									,updcode: ""
									,updname: ""
									,updsort: ""
									,use_status: ""
							});
							code_updateRowEditor.stopEditing();
							code_updateGridStore.insert(0, e);
							code_updateGrid.getView().refresh();
							code_updateGrid.getSelectionModel().selectRow(0);
							code_updateRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_updateRowEditor.stopEditing();
							var s = code_updateGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_updateGridStore.remove(r);
									code_updateGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_updateGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cupdate/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_updateGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cupdate/report?format=pdf");
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
			,store: code_updateGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_updateRowEditor.stopEditing();
		}
	}
});

code_updateGrid.getSelectionModel().on('selectionchange', function(sm){
        code_updateGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
