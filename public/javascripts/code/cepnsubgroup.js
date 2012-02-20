var code_epnsubgroupRowEditor_number = 0;

var code_epnsubgroupFields = [
        {name: "grpcode_tmp", type: "int"}
        ,{name: "grpcode", type: "int"}
        ,{name: "grpnm", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_epnsubgroupNewRecord = Ext.data.Record.create(code_epnsubgroupFields);

var code_epnsubgroupWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         grpcode_tmp: rec.data.grpcode_tmp
         ,grpcode: rec.data.grpcode
         ,grpnm: rec.data.grpnm
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         grpcode_tmp: rec.data.grpcode_tmp
         ,grpcode: rec.data.grpcode
         ,grpnm: rec.data.grpnm
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_epnsubgroupRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_epnsubgroupRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_epnsubgroupRowEditor_number = rowIndex;
                }
        }
});

var code_epnsubgroupcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_epnsubgroupCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "grpcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "หมวด", width: 250, sortable: false, dataIndex: "grpnm", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_epnsubgroupcheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "grpcode", hidden: true}
];

var code_epnsubgroupSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_epnsubgroupProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cepnsubgrp/read'
           ,create: pre_url + '/cepnsubgrp/create'
           ,update: pre_url + '/cepnsubgrp/update'
           ,destroy: pre_url + '/cepnsubgrp/delete'
   }
});

var code_epnsubgroupGridStore = new Ext.data.JsonStore({
        proxy: code_epnsubgroupProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_epnsubgroupFields
        ,idProperty: 'grpcode'
        ,successProperty: 'success'
        ,writer: code_epnsubgroupWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_epnsubgroupGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_epnsubgroupGridStore.removeAt(code_epnsubgroupRowEditor_number);
                                                                        code_epnsubgroupGrid.getView().refresh();
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
                                                                        code_epnsubgroupGridStore.reload();
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

var code_epnsubgroupGrid = new Ext.grid.GridPanel({
	title: "หมวด"
	,region: 'center'
	,split: true
	,store: code_epnsubgroupGridStore
	,columns: code_epnsubgroupCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_epnsubgroupRowEditor,code_epnsubgroupSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_epnsubgroupNewRecord({
									grpcode_tmp: ""
									,grpcode: ""
									,grpnm: ""
									,use_status: ""
							});
							code_epnsubgroupRowEditor.stopEditing();
							code_epnsubgroupGridStore.insert(0, e);
							code_epnsubgroupGrid.getView().refresh();
							code_epnsubgroupGrid.getSelectionModel().selectRow(0);
							code_epnsubgroupRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_epnsubgroupRowEditor.stopEditing();
							var s = code_epnsubgroupGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_epnsubgroupGridStore.remove(r);
									code_epnsubgroupGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_epnsubgroupGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cepnsubgrp/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_epnsubgroupGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cepnsubgrp/report?format=pdf");
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
			,store: code_epnsubgroupGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_epnsubgroupRowEditor.stopEditing();
		}
	}
});

code_epnsubgroupGrid.getSelectionModel().on('selectionchange', function(sm){
        code_epnsubgroupGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
