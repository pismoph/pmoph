var code_tradeRowEditor_number = 0;

var code_tradeFields = [
        {name: "codetrade_tmp", type: "int"}
        ,{name: "codetrade", type: "string"}
        ,{name: "trade", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_tradeNewRecord = Ext.data.Record.create(code_tradeFields);

var code_tradeWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         codetrade_tmp: rec.data.codetrade_tmp
         ,codetrade: rec.data.codetrade	
         ,trade: rec.data.trade
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         codetrade_tmp: rec.data.codetrade_tmp
         ,codetrade: rec.data.codetrade	
         ,trade: rec.data.trade
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_tradeRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_tradeRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_tradeRowEditor_number = rowIndex;
                }
        }
});

var code_tradecheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_tradeCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "codetrade_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ใบอนุญาตประกอบวิชาชีพ", width: 250, sortable: false, dataIndex: "trade", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_tradecheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "codetrade", hidden:true}
];

var code_tradeSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_tradeProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/ctrade/read'
           ,create: pre_url + '/ctrade/create'
           ,update: pre_url + '/ctrade/update'
           ,destroy: pre_url + '/ctrade/delete'
   }
});

var code_tradeGridStore = new Ext.data.JsonStore({
        proxy: code_tradeProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_tradeFields
        ,idProperty: 'codetrade'
        ,successProperty: 'success'
        ,writer: code_tradeWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_tradeGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_tradeGridStore.removeAt(code_tradeRowEditor_number);
                                                                        code_tradeGrid.getView().refresh();
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
                                                                        code_tradeGridStore.reload();
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

var code_tradeGrid = new Ext.grid.GridPanel({
	title: "ใบอนุญาตประกอบวิชาชีพ"
	,region: 'center'
	,split: true
	,store: code_tradeGridStore
	,columns: code_tradeCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_tradeRowEditor,code_tradeSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_tradeNewRecord({
									codetrade_tmp: ""
									,codetrade: ""	
                                                                        ,trade: ""
									,use_status: ""
							});
							code_tradeRowEditor.stopEditing();
							code_tradeGridStore.insert(0, e);
							code_tradeGrid.getView().refresh();
							code_tradeGrid.getSelectionModel().selectRow(0);
							code_tradeRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_tradeRowEditor.stopEditing();
							var s = code_tradeGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_tradeGridStore.remove(r);
									code_tradeGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_tradeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/ctrade/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_tradeGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/ctrade/report?format=pdf");
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
			,store: code_tradeGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_tradeRowEditor.stopEditing();
		}
	}
});

code_tradeGrid.getSelectionModel().on('selectionchange', function(sm){
        code_tradeGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
