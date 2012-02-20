var code_maritalRowEditor_number = 0;

var code_maritalFields = [
        {name: "mrcode_tmp", type: "int"}
        ,{name: "mrcode", type: "string"}
        ,{name: "marital", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_maritalNewRecord = Ext.data.Record.create(code_maritalFields);

var code_maritalWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         mrcode_tmp: rec.data.mrcode_tmp
         ,mrcode: rec.data.mrcode	
         ,marital: rec.data.marital
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         mrcode_tmp: rec.data.mrcode_tmp
         ,mrcode: rec.data.mrcode	
         ,marital: rec.data.marital
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_maritalRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_maritalRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_maritalRowEditor_number = rowIndex;
                }
        }
});

var code_maritalcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_maritalCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "mrcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "สถานภาพสมรส", width: 250, sortable: false, dataIndex: "marital", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_maritalcheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "mrcode", hidden:true}
];

var code_maritalSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_maritalProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cmarital/read'
           ,create: pre_url + '/cmarital/create'
           ,update: pre_url + '/cmarital/update'
           ,destroy: pre_url + '/cmarital/delete'
   }
});

var code_maritalGridStore = new Ext.data.JsonStore({
        proxy: code_maritalProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_maritalFields
        ,idProperty: 'mrcode'
        ,successProperty: 'success'
        ,writer: code_maritalWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_maritalGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_maritalGridStore.removeAt(code_maritalRowEditor_number);
                                                                        code_maritalGrid.getView().refresh();
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
                                                                        code_maritalGridStore.reload();
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

var code_maritalGrid = new Ext.grid.GridPanel({
	title: "สถานภาพสมรส"
	,region: 'center'
	,split: true
	,store: code_maritalGridStore
	,columns: code_maritalCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_maritalRowEditor,code_maritalSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_maritalNewRecord({
									mrcode_tmp: ""
									,mrcode: ""	
                                                                        ,marital: ""
									,use_status: ""
							});
							code_maritalRowEditor.stopEditing();
							code_maritalGridStore.insert(0, e);
							code_maritalGrid.getView().refresh();
							code_maritalGrid.getSelectionModel().selectRow(0);
							code_maritalRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_maritalRowEditor.stopEditing();
							var s = code_maritalGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_maritalGridStore.remove(r);
									code_maritalGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_maritalGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cmarital/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_maritalGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cmarital/report?format=pdf");
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
			,store: code_maritalGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_maritalRowEditor.stopEditing();
		}
	}
});

code_maritalGrid.getSelectionModel().on('selectionchange', function(sm){
        code_maritalGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
