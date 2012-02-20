var code_postypeRowEditor_number = 0;

var code_postypeFields = [
        {name: "ptcode_tmp", type: "int"}
        ,{name: "ptcode", type: "int"}
        ,{name: "ptname", type: "string"}
        ,{name: "shortmn", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_postypeNewRecord = Ext.data.Record.create(code_postypeFields);

var code_postypeWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         ptcode_tmp: rec.data.ptcode_tmp
         ,ptcode: rec.data.ptcode
         ,ptname: rec.data.ptname
         ,shortmn: rec.data.shortmn
         ,use_status: rec.data.use_status
      };
      return data;   
   }
   ,updateRecord : function(rec) {
      data = {
         ptcode_tmp: rec.data.ptcode_tmp
         ,ptcode: rec.data.ptcode
         ,ptname: rec.data.ptname
         ,shortmn: rec.data.shortmn
         ,use_status: rec.data.use_status
      };
      return data;
   }  
});

var code_postypeRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_postypeRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_postypeRowEditor_number = rowIndex;
                }
        }
});

var code_postypecheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_postypeCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "ptcode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
        ,{header: "ประเภท", width: 250, sortable: false, dataIndex: "ptname", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "คำย่อ", width: 100, sortable: false, dataIndex: "shortmn", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_postypecheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "ptcode",hidden: true}
];

var code_postypeSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_postypeProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cpostype/read'
           ,create: pre_url + '/cpostype/create'
           ,update: pre_url + '/cpostype/update'
           ,destroy: pre_url + '/cpostype/delete'
   }
});

var code_postypeGridStore = new Ext.data.JsonStore({
        proxy: code_postypeProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_postypeFields
        ,idProperty: 'ptcode'
        ,successProperty: 'success'
        ,writer: code_postypeWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_postypeGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_postypeGridStore.removeAt(code_postypeRowEditor_number);
                                                                        code_postypeGrid.getView().refresh();
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
                                                                        code_postypeGridStore.reload();
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

var code_postypeGrid = new Ext.grid.GridPanel({
	title: "ว. / วช. / ชช."
	,region: 'center'
	,split: true
	,store: code_postypeGridStore
	,columns: code_postypeCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_postypeRowEditor,code_postypeSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_postypeNewRecord({
									ptcode_tmp: ""
									,ptcode: ""
									,ptname: ""
									,shortmn: ""
									,use_status: ""
							});
							code_postypeRowEditor.stopEditing();
							code_postypeGridStore.insert(0, e);
							code_postypeGrid.getView().refresh();
							code_postypeGrid.getSelectionModel().selectRow(0);
							code_postypeRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_postypeRowEditor.stopEditing();
							var s = code_postypeGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_postypeGridStore.remove(r);
									code_postypeGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_postypeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cpostype/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_postypeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cpostype/report?format=pdf");
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
			,store: code_postypeGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_postypeRowEditor.stopEditing();
		}
	}
});

code_postypeGrid.getSelectionModel().on('selectionchange', function(sm){
        code_postypeGrid.removeBtn.setDisabled(sm.getCount() < 1);
});