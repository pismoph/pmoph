var code_expertRowEditor_number = 0;

var code_expertFields = [
        {name: "epcode_tmp", type: "int"}
        ,{name: "epcode", type: "int"}
        ,{name: "prename", type: "string"}
        ,{name: "expert", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_expertNewRecord = Ext.data.Record.create(code_expertFields);

var code_expertWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         epcode_tmp: rec.data.epcode_tmp
         ,epcode: rec.data.epcode
         ,prename: rec.data.prename
         ,expert: rec.data.expert
         ,use_status: rec.data.use_status
      };
      return data;   
   }
   ,updateRecord : function(rec) {
      data = {
         epcode_tmp: rec.data.epcode_tmp
         ,epcode: rec.data.epcode
         ,prename: rec.data.prename
         ,expert: rec.data.expert
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_expertRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_expertRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_expertRowEditor_number = rowIndex;
                }
        }
});

var code_expertcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_expertCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัสความเชี่ยวชาญ", width: 100, sortable: false, dataIndex: "epcode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
        ,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "prename", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "ความเชี่ยวชาญ", width: 250, sortable: false, dataIndex: "expert", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_expertcheckColumn
        ,{header: "รหัสความเชี่ยวชาญ", width: 100, sortable: false, dataIndex: "epcode",hidden: true}
];

var code_expertSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_expertProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cexpert/read'
           ,create: pre_url + '/cexpert/create'
           ,update: pre_url + '/cexpert/update'
           ,destroy: pre_url + '/cexpert/delete'
   }
});

var code_expertGridStore = new Ext.data.JsonStore({
        proxy: code_expertProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_expertFields
        ,idProperty: 'epcode'
        ,successProperty: 'success'
        ,writer: code_expertWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_expertGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_expertGridStore.removeAt(code_expertRowEditor_number);
                                                                        code_expertGrid.getView().refresh();
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
                                                                        code_expertGridStore.reload();
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

var code_expertGrid = new Ext.grid.GridPanel({
	title: "ความเชี่ยวชาญ"
	,region: 'center'
	,split: true
	,store: code_expertGridStore
	,columns: code_expertCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_expertRowEditor,code_expertSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_expertNewRecord({
									epcode_tmp: ""
									,epcode: ""
									,prename: ""
									,expert: ""
									,use_status: ""
							});
							code_expertRowEditor.stopEditing();
							code_expertGridStore.insert(0, e);
							code_expertGrid.getView().refresh();
							code_expertGrid.getSelectionModel().selectRow(0);
							code_expertRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_expertRowEditor.stopEditing();
							var s = code_expertGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_expertGridStore.remove(r);
									code_expertGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_expertGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cexpert/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_expertGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cexpert/report?format=pdf");
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
			,store: code_expertGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_expertRowEditor.stopEditing();
		}
	}		
});

code_expertGrid.getSelectionModel().on('selectionchange', function(sm){
        code_expertGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
