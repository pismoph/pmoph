var code_amphurRowEditor_number = 0;

var code_amphurFields = [
	{name: "amcode_tmp",type: 'int'}
	,{name: "amcode",type: 'int'}
	,{name: "provcode",type: 'int'}
	,{name: "shortpre",type: 'string'}
	,{name: "longpre",type: 'string'}
	,{name: "amname",type: 'string'}
	,{name: "use_status",type: 'bool'}
];	

var code_amphurNewRecord = Ext.data.Record.create(code_amphurFields);

var code_amphurWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 amcode_tmp: rec.data.amcode_tmp
	 ,amcode: rec.data.amcode
	 ,provcode: rec.data.provcode
	 ,shortpre: rec.data.shortpre
	 ,longpre: rec.data.longpre
	 ,amname: rec.data.amname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
	 amcode_tmp: rec.data.amcode_tmp
	 ,amcode: rec.data.amcode
	 ,provcode: rec.data.provcode
	 ,shortpre: rec.data.shortpre
	 ,longpre: rec.data.longpre
	 ,amname: rec.data.amname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_amphurRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj,data, rowIndex ) {	
			loadMask.show();
			code_amphurRowEditor_number  = rowIndex
		}
		,canceledit: function(rowEditor, obj,data, rowIndex ) {	
			code_amphurRowEditor_number  = rowIndex
		}
	}

});

var code_amphurcheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_amphurCols = [
	{
		header: "#"
		,width: 50
		,renderer: rowNumberer.createDelegate(this)
		, sortable: false
	},{
		header: "รหัสอำเภอ"
		,width: 100
		,sortable: false
		,dataIndex: 'amcode_tmp'
		,editor: new Ext.form.NumberField({allowBlank: false})
	},{
		header: "ชื่อย่อคำนำหน้าอำเภอ"
		,width: 150
		,sortable: false
		,dataIndex: 'shortpre'
		,editor: new Ext.form.TextField()
	},{
		header: "คำนำหน้าอำเภอ"
		,width: 100
		,sortable: false
		,dataIndex: 'longpre'
		,editor: new Ext.form.TextField()
	},{
		header: "อำเภอ"
		,width: 100
		,sortable: false
		,dataIndex: 'amname'
		,editor: new Ext.form.TextField()
	}
	,code_amphurcheckColumn
	,{header: "รหัสจ.", width: 100, sortable: false, dataIndex: "provcode",hidden: true}
	,{header: "รหัสอำเภอ", width: 100, sortable: false, dataIndex: "amcode",hidden: true}
];	

var code_amphurSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_amphurProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url + '/camphur/read'
	   ,create: pre_url + '/camphur/create'
	   ,update: pre_url + '/camphur/update'
	   ,destroy: pre_url + '/camphur/delete'
   }
});	

var code_amphurGridStore = new Ext.data.JsonStore({
	proxy: code_amphurProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_amphurFields
	,idProperty: 'amcode'
	,successProperty: 'success'
	,writer: code_amphurWriter
	,autoSave: true
	,listeners: {
		write: function (store,action,result,res,rs){
			if (res.success == true)
			{
				code_amphurGridStore.load({ params: { start: 0, limit: 20} });
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
						Ext.Msg.alert("สถานะ",obj.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_amphurGridStore.removeAt(code_amphurRowEditor_number);
									code_amphurGrid.getView().refresh();
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
						Ext.Msg.alert("สถานะ",res.raw.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_amphurGridStore.reload();
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

var code_amphurGrid = new Ext.grid.GridPanel({
	title: "อำเภอ"
	,region: 'center'
	,disabled: true
	,split: true
	,store: code_amphurGridStore
	,columns: code_amphurCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_amphurRowEditor,code_amphurSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_amphurNewRecord({
						amcode_tmp: ""
						,amcode: ""
						,provcode: ca_source_province.getValue()
						,shortpre: ""
						,longpre: ""
						,amname: ""
						,use_status: ""
				});
				code_amphurRowEditor.stopEditing();
				code_amphurGridStore.insert(0, e);
				code_amphurGrid.getView().refresh();
				code_amphurGrid.getSelectionModel().selectRow(0);
				code_amphurRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn',
			text: 'ลบ',
			tooltip: 'ลบ',
			iconCls: 'table-delete',
			disabled: true,
			handler: function(){
				loadMask.show();
				code_amphurRowEditor.stopEditing();
				var s = code_amphurGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_amphurGridStore.remove(r);
					code_amphurGrid.getView().refresh();
				}
			}
		},"-",{
			text: "Export",
			iconCls: "door-out",
			menu: {
				items: [
					{
						text: "Excel",
						iconCls: "excel",
						handler: function() {

							var data = Ext.util.JSON.encode(code_amphurGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/camphur/report?format=xls");
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
						text: "PDF",
						iconCls: "pdf",
						handler: function() {

							var data = Ext.util.JSON.encode(code_amphurGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/camphur/report?format=pdf");
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
		,store: code_amphurGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
	,listeners: {
		beforedestroy: function(p){
			code_amphurRowEditor.stopEditing();
		}
	}
});

code_amphurGrid.getSelectionModel().on('selectionchange', function(sm){
	code_amphurGrid.removeBtn.setDisabled(sm.getCount() < 1);
});

var ca_source_province = new Ext.ux.form.PisComboBox({
   valueField: 'provcode'
   ,displayField: 'provname'
   ,urlStore: pre_url + '/code/cprovince'
   ,fieldStore: ['provcode', 'provname']
   ,listeners:{																							
       select: function(){
	       delete(code_amphurGridStore.baseParams["provcode"]);
	       if (code_amphurGridStore.lastOptions && code_amphurGridStore.lastOptions.params) {
		       delete(code_amphurGridStore.lastOptions.params["provcode"]);
	       }										
	       code_amphurGridStore.baseParams["provcode"] = ca_source_province.getValue();
	       code_amphurGridStore.load({ params: { start: 0, limit: 20} });
	       code_amphurGrid.enable();
       }
   }
});

var code_amphurNorth = new Ext.Panel({
	region: "north"
	,layout: 'hbox' 
	,height: 50
	,layoutConfig: { 
		align: 'middle'
		,pack: "center"
	}
	,items: [
			{
				xtype: "label"
				,text: "จังหวัด:"
				,margins:'0 5 0 0'
			}
			,ca_source_province		
	]
});


var code_amphurPanel = new Ext.Panel({
	layout: "border"
	,items: [
		code_amphurGrid,code_amphurNorth
	]
	,listeners: {
		beforedestroy: function(p){
			code_amphurRowEditor.stopEditing();
		}
	}
});