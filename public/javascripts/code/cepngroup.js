var code_epngroupRowEditor_number = 0;

var code_epngroupFields = [
        {name: "gcode_tmp", type: "int"}
        ,{name: "gcode", type: "int"}
        ,{name: "gname", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_epngroupNewRecord = Ext.data.Record.create(code_epngroupFields);

var code_epngroupWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         gcode_tmp: rec.data.gcode_tmp
         ,gcode: rec.data.gcode
         ,gname: rec.data.gname
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         gcode_tmp: rec.data.gcode_tmp
         ,gcode: rec.data.gcode
         ,gname: rec.data.gname
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_epngroupRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_epngroupRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_epngroupRowEditor_number = rowIndex;
                }
        }
});

var code_epngroupcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_epngroupCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัสกลุ่ม", width: 100, sortable: false, dataIndex: "gcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ชื่อกลุ่ม", width: 250, sortable: false, dataIndex: "gname", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_epngroupcheckColumn
        ,{header: "รหัสกลุ่ม", width: 100, sortable: false, dataIndex: "gcode", hidden:true}
];

var code_epngroupSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_epngroupProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cepngroup/read'
           ,create: pre_url + '/cepngroup/create'
           ,update: pre_url + '/cepngroup/update'
           ,destroy: pre_url + '/cepngroup/delete'
   }
});

var code_epngroupGridStore = new Ext.data.JsonStore({
        proxy: code_epngroupProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_epngroupFields
        ,idProperty: 'gcode'
        ,successProperty: 'success'
        ,writer: code_epngroupWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_epngroupGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_epngroupGridStore.removeAt(code_epngroupRowEditor_number);
                                                                        code_epngroupGrid.getView().refresh();
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
                                                                        code_epngroupGridStore.reload();
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

var code_epngroupGrid = new Ext.grid.GridPanel({
	title: "กลุ่ม"
	,region: 'center'
	,split: true
	,store: code_epngroupGridStore
	,columns: code_epngroupCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_epngroupRowEditor,code_epngroupSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_epngroupNewRecord({
									gcode_tmp: ""
									,gcode: ""
									,gname: ""
									,use_status: ""
							});
							code_epngroupRowEditor.stopEditing();
							code_epngroupGridStore.insert(0, e);
							code_epngroupGrid.getView().refresh();
							code_epngroupGrid.getSelectionModel().selectRow(0);
							code_epngroupRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_epngroupRowEditor.stopEditing();
							var s = code_epngroupGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_epngroupGridStore.remove(r);
									code_epngroupGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_epngroupGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cepngroup/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_epngroupGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cepngroup/report?format=pdf");
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
			,store: code_epngroupGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_epngroupRowEditor.stopEditing();
		}
	}
});

code_epngroupGrid.getSelectionModel().on('selectionchange', function(sm){
        code_epngroupGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
