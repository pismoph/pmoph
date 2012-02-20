var code_religRowEditor_number = 0;

var code_religFields = [
        {name: "recode_tmp", type: "int"}
        ,{name: "recode", type: "string"}
        ,{name: "renname", type: "string"}
        ,{name: "use_status", type: "bool"}
];

var code_religNewRecord = Ext.data.Record.create(code_religFields);

var code_religWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         recode_tmp: rec.data.recode_tmp
         ,recode: rec.data.recode	
         ,renname: rec.data.renname
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         recode_tmp: rec.data.recode_tmp
         ,recode: rec.data.recode	
         ,renname: rec.data.renname
         ,use_status: rec.data.use_status
      };
      return data;
   }   
});

var code_religRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_religRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_religRowEditor_number = rowIndex;
                }
        }
});

var code_religcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_religCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "recode_tmp", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ศาสนา", width: 250, sortable: false, dataIndex: "renname", editor: new Ext.form.TextField({allowBlank: false})}
        ,code_religcheckColumn
        ,{header: "รหัส", width: 100, sortable: false, dataIndex: "recode", hidden:true}
];

var code_religSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_religProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/creligion/read'
           ,create: pre_url + '/creligion/create'
           ,update: pre_url + '/creligion/update'
           ,destroy: pre_url + '/creligion/delete'
   }
});

var code_religGridStore = new Ext.data.JsonStore({
        proxy: code_religProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_religFields
        ,idProperty: 'recode'
        ,successProperty: 'success'
        ,writer: code_religWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_religGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_religGridStore.removeAt(code_religRowEditor_number);
                                                                        code_religGrid.getView().refresh();
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
                                                                        code_religGridStore.reload();
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

var code_religGrid = new Ext.grid.GridPanel({
	title: "ศาสนา"
	,region: 'center'
	,split: true
	,store: code_religGridStore
	,columns: code_religCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_religRowEditor,code_religSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_religNewRecord({
									recode_tmp: ""
									,recode: ""	
                                                                        ,renname: ""
									,use_status: ""
							});
							code_religRowEditor.stopEditing();
							code_religGridStore.insert(0, e);
							code_religGrid.getView().refresh();
							code_religGrid.getSelectionModel().selectRow(0);
							code_religRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_religRowEditor.stopEditing();
							var s = code_religGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_religGridStore.remove(r);
									code_religGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_religGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/creligion/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_religGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/creligion/report?format=pdf");
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
			,store: code_religGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_religRowEditor.stopEditing();
		}
	}
});

code_religGrid.getSelectionModel().on('selectionchange', function(sm){
        code_religGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
