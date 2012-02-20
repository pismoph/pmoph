var code_abtypeRowEditor_number = 0;

var code_abtypeFields = [
        {name: "abcode_tmp", type: "int"}
        ,{name: "abcode", type: "int"}
        ,{name: "abtype", type: "string"}
        ,{name: "chk", type: "bool"}
        ,{name: "cnt", type: "bool"}
        ,{name: "abquota", type: "int"}
        ,{name: "use_status", type: "bool"}
];

var code_abtypeNewRecord = Ext.data.Record.create(code_abtypeFields);

var code_abtypeWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         abcode_tmp: rec.data.abcode_tmp
         ,abcode: rec.data.abcode
         ,abtype: rec.data.abtype
         ,chk: rec.data.chk
         ,cnt: rec.data.cnt
         ,abquota: rec.data.abquota
         ,use_status: rec.data.use_status  
      };
      return data;   
   }
   ,updateRecord : function(rec) {
      data = {
         abcode_tmp: rec.data.abcode_tmp
         ,abcode: rec.data.abcode
         ,abtype: rec.data.abtype
         ,chk: rec.data.chk
         ,cnt: rec.data.cnt
         ,abquota: rec.data.abquota
         ,use_status: rec.data.use_status  
      };
      return data;
   }   
});

var code_abtypeRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_abtypeRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_abtypeRowEditor_number = rowIndex;
                }
        }
});

var code_abtypecheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var chkCheckColumn = new Ext.grid.CheckColumn({
        header: 'นับจำนวนครั้ง'
        ,dataIndex: 'chk'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var cntCheckColumn = new Ext.grid.CheckColumn({
        header: 'นับจำนวนวัน'
        ,dataIndex: 'cnt'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_abtypeCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "abcode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ประเภทการลา", width: 250, sortable: false, dataIndex: "abtype", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "โควตา", width: 100, sortable: false, dataIndex: "abquota", editor: new Ext.form.NumberField({allowBlank: false})}
        ,chkCheckColumn
        ,cntCheckColumn
        ,code_abtypecheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "abcode", hidden: true}
];

var code_abtypeSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_abtypeProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cabsenttype/read'
           ,create: pre_url + '/cabsenttype/create'
           ,update: pre_url + '/cabsenttype/update'
           ,destroy: pre_url + '/cabsenttype/delete'
   }
});

var code_abtypeGridStore = new Ext.data.JsonStore({
        proxy: code_abtypeProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_abtypeFields
        ,idProperty: 'abcode'
        ,successProperty: 'success'
        ,writer: code_abtypeWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_abtypeGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_abtypeGridStore.removeAt(code_abtypeRowEditor_number);
                                                                        code_abtypeGrid.getView().refresh();
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
                                                                        code_abtypeGridStore.reload();
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

var code_abtypeGrid = new Ext.grid.GridPanel({
	title: "ประเภทการลา"
	,region: 'center'
	,split: true
	,store: code_abtypeGridStore
	,columns: code_abtypeCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_abtypeRowEditor,code_abtypeSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_abtypeNewRecord({
									abcode_tmp: ""
									,abcode: ""
									,abtype: ""
									,chk: ""
									,cnt: ""
									,abquota: ""
									,use_status: ""
							});
							code_abtypeRowEditor.stopEditing();
							code_abtypeGridStore.insert(0, e);
							code_abtypeGrid.getView().refresh();
							code_abtypeGrid.getSelectionModel().selectRow(0);
							code_abtypeRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_abtypeRowEditor.stopEditing();
							var s = code_abtypeGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_abtypeGridStore.remove(r);
									code_abtypeGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_abtypeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cabsenttype/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_abtypeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cabsenttype/report?format=pdf");
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
			,store: code_abtypeGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_abtypeRowEditor.stopEditing();
		}
	}
});

code_abtypeGrid.getSelectionModel().on('selectionchange', function(sm){
        code_abtypeGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
