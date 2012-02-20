var code_j18statusRowEditor_number = 0;

var code_j18statusFields = [
        {name: "j18code_tmp", type: "int"}
        ,{name: "j18code", type: "string"}
        ,{name: "j18status", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_j18statusNewRecord = Ext.data.Record.create(code_j18statusFields);

var code_j18statusWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         j18code_tmp: rec.data.j18code_tmp
         ,j18code: rec.data.j18code	
         ,j18status: rec.data.j18status
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         j18code_tmp: rec.data.j18code_tmp
         ,j18code: rec.data.j18code	
         ,j18status: rec.data.j18status
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_j18statusRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_j18statusRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_j18statusRowEditor_number = rowIndex;
                }
        }
});

var code_j18statuscheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_j18statusCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "j18code_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "สถานะตาม จ.18", width: 250, sortable: false, dataIndex: "j18status", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_j18statuscheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "j18code", hidden:true}
];

var code_j18statusSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_j18statusProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cj18status/read'
           ,create: pre_url + '/cj18status/create'
           ,update: pre_url + '/cj18status/update'
           ,destroy: pre_url + '/cj18status/delete'
   }
});

var code_j18statusGridStore = new Ext.data.JsonStore({
        proxy: code_j18statusProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_j18statusFields
        ,idProperty: 'j18code'
        ,successProperty: 'success'
        ,writer: code_j18statusWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_j18statusGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_j18statusGridStore.removeAt(code_j18statusRowEditor_number);
                                                                        code_j18statusGrid.getView().refresh();
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
                                                                        code_j18statusGridStore.reload();
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

var code_j18statusGrid = new Ext.grid.GridPanel({
	title: "สถานะตาม จ.18"
	,region: 'center'
	,split: true
	,store: code_j18statusGridStore
	,columns: code_j18statusCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_j18statusRowEditor,code_j18statusSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_j18statusNewRecord({
									j18code_tmp: ""
									,j18code: ""	
                                                                        ,j18status: ""
									,use_status: ""
							});
							code_j18statusRowEditor.stopEditing();
							code_j18statusGridStore.insert(0, e);
							code_j18statusGrid.getView().refresh();
							code_j18statusGrid.getSelectionModel().selectRow(0);
							code_j18statusRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_j18statusRowEditor.stopEditing();
							var s = code_j18statusGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_j18statusGridStore.remove(r);
									code_j18statusGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_j18statusGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cj18status/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_j18statusGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cj18status/report?format=pdf");
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
			,store: code_j18statusGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_j18statusRowEditor.stopEditing();
		}
	}
});

code_j18statusGrid.getSelectionModel().on('selectionchange', function(sm){
        code_j18statusGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
