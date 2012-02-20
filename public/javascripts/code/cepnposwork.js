var code_epnposworkRowEditor_number = 0;
var code_epnposworkFields = [
        {name: "wrkcode_tmp", type: "int"}
        ,{name: "wrkcode", type: "int"}
        ,{name: "gcode", type: "int"}
        ,{name: "grpcode", type: "int"}
        ,{name: "wrknm", type: "string"}
        ,{name: "levels", type: "int"}
        ,{name: "minwages", type: "float"}
        ,{name: "maxwages", type: "float"}
        ,{name: "wrkatrb", type: "string"}
        ,{name: "note", type: "string"}
        ,{name: "numcode", type: "int"}
        ,{name: "use_status", type: "bool"}
];

var code_epnposworkNewRecord = Ext.data.Record.create(code_epnposworkFields);

var code_epnposworkWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
         wrkcode_tmp: rec.data.wrkcode_tmp
         ,wrkcode: rec.data.wrkcode
         ,gcode: rec.data.gcode
         ,grpcode: rec.data.grpcode
         ,wrknm: rec.data.wrknm
         ,levels: rec.data.levels
         ,minwages: rec.data.minwages
         ,maxwages: rec.data.maxwages
         ,wrkatrb: rec.data.wrkatrb
         ,note: rec.data.note
         ,numcode: rec.data.numcode
         ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
         wrkcode_tmp: rec.data.wrkcode_tmp
         ,wrkcode: rec.data.wrkcode
         ,gcode: rec.data.gcode
         ,grpcode: rec.data.grpcode
         ,wrknm: rec.data.wrknm
         ,levels: rec.data.levels
         ,minwages: rec.data.minwages
         ,maxwages: rec.data.maxwages
         ,wrkatrb: rec.data.wrkatrb
         ,note: rec.data.note
         ,numcode: rec.data.numcode
         ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_epnposworkRowEditor = new Ext.ux.grid.RowEditor({
        saveText: 'บันทึก'
        ,cancelText: 'ยกเลิก'
        ,listeners: {
                validateedit: function(rowEditor, obj, data, rowIndex ) {
                        loadMask.show();
                        code_epnposworkRowEditor_number = rowIndex;
                }
                ,canceledit: function(rowEditor, obj, data, rowIndex ) {
                        code_epnposworkRowEditor_number = rowIndex;
                }
        }
});

var code_epnposworkcheckColumn = new Ext.grid.CheckColumn({
        header: 'สถานะการใช้งาน'
        ,dataIndex: 'use_status'
        ,width: 100
        ,editor: new Ext.form.Checkbox()
});

var code_epnposworkCols = [
        {
                header: "#"
                ,width: 50
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "รหัสตำแหน่ง", width: 80, sortable: false, dataIndex: "wrkcode_tmp", editor: new Ext.form.NumberField({allowBlank: false })}
        ,{header: "รหัสกลุ่ม", width: 50, sortable: false, dataIndex: "gcode", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "รหัสหมวด", width: 80, sortable: false, dataIndex: "grpcode", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ชื่อตำแหน่ง", width: 100, sortable: false, dataIndex: "wrknm", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "ระดับ", width: 50, sortable: false, dataIndex: "levels", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ค่าจ้างขั้นต่ำ", width: 80, sortable: false, dataIndex: "minwages", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "ค่าจ้างขั้นสูง", width: 80, sortable: false, dataIndex: "maxwages", editor: new Ext.form.NumberField({allowBlank: false})}
        ,{header: "attribute", width: 100, sortable: false, dataIndex: "wrkatrb", editor: new Ext.form.TextField({allowBlank: false})}
        ,{header: "หมายเหตุ", width: 100, sortable: false, dataIndex: "note", editor: new Ext.form.TextField()}
        ,{header: "รหัสตัวเลข", width: 80, sortable: false, dataIndex: "numcode", editor: new Ext.form.NumberField({allowBlank: false})}
        ,code_epnposworkcheckColumn
        ,{header: "รหัสตำแหน่ง", width: 80, sortable: false, dataIndex: "wrkcode", hidden: true}
];

var code_epnposworkSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});

var code_epnposworkProxy = new Ext.data.HttpProxy({
   api: {
           read: pre_url + '/cepnposwork/read'
           ,create: pre_url + '/cepnposwork/create'
           ,update: pre_url + '/cepnposwork/update'
           ,destroy: pre_url + '/cepnposwork/delete'
   }
});

var code_epnposworkGridStore = new Ext.data.JsonStore({
        proxy: code_epnposworkProxy
        ,root: 'records'
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,remoteSort: true
        ,fields: code_epnposworkFields
        ,idProperty: 'wrkcode'
        ,successProperty: 'success'
        ,writer: code_epnposworkWriter
        ,autoSave: true
        ,listeners: {
                write: function (store, action, result, res, rs){
                        if (res.success == true)
                        {
                                code_epnposworkGridStore.load({ params: { start: 0, limit: 20} });
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
                                                                        code_epnposworkGridStore.removeAt(code_epnposworkRowEditor_number);
                                                                        code_epnposworkGrid.getView().refresh();
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
                                                                        code_epnposworkGridStore.reload();
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

var code_epnposworkGrid = new Ext.grid.GridPanel({
	title: "ตำแหน่งลูกจ้างประจำ"
	,region: 'center'
	,split: true
	,store: code_epnposworkGridStore
	,columns: code_epnposworkCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_epnposworkRowEditor,code_epnposworkSearch]
	,tbar: [
			{
					text: 'เพิ่ม'
					,tooltip: 'เพิ่ม'
					,iconCls: 'table-add'
					,handler: function(){
							var e = new code_epnposworkNewRecord({
									wrkcode_tmp: ""
									,wrkcode: ""
									,gcode: ""
									,grpcode: ""
									,wrknm: ""
									,levels: ""
									,minwages: ""
									,maxwages: ""
									,wrkatrb: ""
									,note: ""
									,numcode: ""
									,use_status: ""
							});
							code_epnposworkRowEditor.stopEditing();
							code_epnposworkGridStore.insert(0, e);
							code_epnposworkGrid.getView().refresh();
							code_epnposworkGrid.getSelectionModel().selectRow(0);
							code_epnposworkRowEditor.startEditing(0);
					}
			},"-",{
					ref: '../removeBtn'
					,text: 'ลบ'
					,tooltip: 'ลบ'
					,iconCls: 'table-delete'
					,disabled: true
					,handler: function(){
							loadMask.show();
							code_epnposworkRowEditor.stopEditing();
							var s = code_epnposworkGrid.getSelectionModel().getSelections();
							for(var i = 0, r; r = s[i]; i++){
									code_epnposworkGridStore.remove(r);
									code_epnposworkGrid.getView().refresh();
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
													var data = Ext.util.JSON.encode(code_epnposworkGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cepnposwork/report?format=xls");
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
													var data = Ext.util.JSON.encode(code_epnposworkGridStore.lastOptions.params);
													var form = document.createElement("form");
													form.setAttribute("method", "post");
													form.setAttribute("action", pre_url + "/cepnposwork/report?format=pdf");
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
			,store: code_epnposworkGridStore
			,displayInfo: true
			,displayMsg: 'Displaying {0} - {1} of {2}'
			,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_epnposworkRowEditor.stopEditing();
		}
	}
});

code_epnposworkGrid.getSelectionModel().on('selectionchange', function(sm){
        code_epnposworkGrid.removeBtn.setDisabled(sm.getCount() < 1);
});
